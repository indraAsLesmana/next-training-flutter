import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes, users, tasks, submissions } from './db/schema';
import { eq, and } from 'drizzle-orm';

const app = new Hono();

app.use('*', cors());

// Helper Koneksi Drizzle Client
function getDb() {
  const sql = neon(process.env.DATABASE_URL!);
  return drizzle(sql);
}

// -------------------------------------------------------------
// GET: Master Kelas
// -------------------------------------------------------------
app.get('/api/classes', async (c) => {
  const db = getDb();
  try {
    const data = await db.select().from(classes);
    return c.json({ success: true, data });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Register User
// -------------------------------------------------------------
app.post('/api/auth/register', async (c) => {
  const db = getDb();
  const { nama, role, nipNik, email, password, classId } = await c.req.json();

  try {
    const newUser = await db.insert(users).values({
      nama,
      role,
      nipNik,
      email: email || null,
      passwordHash: password, // Di produksi: gunakan bcrypt/argon2
      classId: role === 'guru' ? null : classId,
    }).returning();

    return c.json({ success: true, data: newUser[0] }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Login User
// -------------------------------------------------------------
app.post('/api/auth/login', async (c) => {
  const db = getDb();
  const { nipNik, password } = await c.req.json();

  try {
    const foundUsers = await db
      .select()
      .from(users)
      .where(and(eq(users.nipNik, nipNik), eq(users.passwordHash, password)));

    if (foundUsers.length === 0) {
      return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
    }

    return c.json({ success: true, data: foundUsers[0] }, 200);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// GET: List Tasks (Filterable by classId, guruId, or siswaId)
// -------------------------------------------------------------
app.get('/api/tasks', async (c) => {
  const db = getDb();
  const classId = c.req.query('classId');
  const guruId = c.req.query('guruId');
  const siswaId = c.req.query('siswaId');

  try {
    const conditions = [];
    if (classId) conditions.push(eq(tasks.classId, classId));
    if (guruId) conditions.push(eq(tasks.guruId, guruId));

    const taskList = conditions.length > 0
      ? await db.select().from(tasks).where(and(...conditions))
      : await db.select().from(tasks);

    if (siswaId) {
      const userSubmissions = await db
        .select()
        .from(submissions)
        .where(eq(submissions.siswaId, siswaId));
      
      const submissionMap = new Map(userSubmissions.map(s => [s.taskId, s]));

      const data = taskList.map(task => {
        const sub = submissionMap.get(task.id);
        return {
          ...task,
          isSubmitted: !!sub,
          submittedAt: sub ? sub.submittedAt : null,
          submitUrl: sub ? sub.submitUrl : null,
          submissionNotes: sub ? sub.notes : null,
        };
      });

      return c.json({ success: true, data });
    }

    return c.json({ success: true, data: taskList });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Guru Tambah Tugas Baru
// -------------------------------------------------------------
app.post('/api/tasks', async (c) => {
  const db = getDb();
  const { guruId, classId, description, startDate, endDate, attachmentUrl } = await c.req.json();

  try {
    const newTask = await db.insert(tasks).values({
      guruId,
      classId,
      description,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      attachmentUrl: attachmentUrl || null,
    }).returning();

    return c.json({ success: true, data: newTask[0] }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Siswa Submit / Edit Tugas
// -------------------------------------------------------------
app.post('/api/submissions', async (c) => {
  const db = getDb();
  const { taskId, siswaId, submitUrl, notes } = await c.req.json();

  try {
    const existing = await db
      .select()
      .from(submissions)
      .where(and(eq(submissions.taskId, taskId), eq(submissions.siswaId, siswaId)));

    let result;
    if (existing.length > 0) {
      const updated = await db
        .update(submissions)
        .set({
          submitUrl,
          notes: notes || null,
          submittedAt: new Date(),
        })
        .where(eq(submissions.id, existing[0].id))
        .returning();
      result = updated[0];
    } else {
      const inserted = await db
        .insert(submissions)
        .values({
          taskId,
          siswaId,
          submitUrl,
          notes: notes || null,
        })
        .returning();
      result = inserted[0];
    }

    return c.json({ success: true, data: result }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// GET: Detail Submissions per Task (for Teacher)
// -------------------------------------------------------------
app.get('/api/tasks/:id/submissions', async (c) => {
  const db = getDb();
  const taskId = c.req.param('id');

  try {
    const taskData = await db.select().from(tasks).where(eq(tasks.id, taskId));
    if (taskData.length === 0) {
      return c.json({ success: false, message: 'Tugas tidak ditemukan' }, 404);
    }
    const task = taskData[0];

    const studentsInClass = await db
      .select()
      .from(users)
      .where(and(eq(users.role, 'siswa'), eq(users.classId, task.classId)));

    const taskSubmissions = await db
      .select()
      .from(submissions)
      .where(eq(submissions.taskId, taskId));

    const submissionMap = new Map(taskSubmissions.map((s) => [s.siswaId, s]));

    const studentList = studentsInClass.map((student) => {
      const sub = submissionMap.get(student.id);
      return {
        siswaId: student.id,
        nama: student.nama,
        nipNik: student.nipNik,
        email: student.email,
        isSubmitted: !!sub,
        submitUrl: sub ? sub.submitUrl : null,
        notes: sub ? sub.notes : null,
        submittedAt: sub ? sub.submittedAt : null,
      };
    });

    return c.json({
      success: true,
      data: {
        task,
        students: studentList,
      },
    });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

export default app;