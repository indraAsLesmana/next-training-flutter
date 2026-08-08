import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes, users, tasks, submissions } from './db/schema';
import { eq } from 'drizzle-orm';
import { hashPassword, verifyPassword, signToken, authMiddleware, requireRole, AuthVariables } from './auth';

const app = new Hono<{ Variables: AuthVariables }>();

app.use('*', cors());

// Helper Koneksi Drizzle Client
function getDb() {
  const sql = neon(process.env.DATABASE_URL!);
  return drizzle(sql);
}

// -------------------------------------------------------------
// GET: Master Kelas (publik — dibutuhkan saat registrasi)
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

  if (!password || password.length < 6) {
    return c.json({ success: false, message: 'Password minimal 6 karakter' }, 400);
  }

  try {
    // Selalu hash password sebelum disimpan — JANGAN simpan plaintext!
    const passwordHash = await hashPassword(password);

    const newUser = await db.insert(users).values({
      nama,
      role,
      nipNik,
      email: email || null,
      passwordHash,
      classId: role === 'guru' ? null : classId,
    }).returning({
      id: users.id,
      nama: users.nama,
      role: users.role,
      nipNik: users.nipNik,
      email: users.email,
      classId: users.classId,
      createdAt: users.createdAt,
    });

    // Generate token langsung setelah registrasi agar user langsung login
    const token = await signToken(newUser[0]);
    return c.json({ success: true, data: newUser[0], token }, 201);
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
      .where(eq(users.nipNik, nipNik));

    if (foundUsers.length === 0) {
      return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
    }

    const user = foundUsers[0];
    const passwordMatch = await verifyPassword(password, user.passwordHash);

    if (!passwordMatch) {
      return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
    }

    const token = await signToken(user);
    return c.json({
      success: true,
      data: {
        id: user.id,
        nama: user.nama,
        role: user.role,
        nipNik: user.nipNik,
        email: user.email,
        classId: user.classId,
        createdAt: user.createdAt,
      },
      token,
    }, 200);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// Semua route di bawah ini butuh autentikasi (Bearer token)
// -------------------------------------------------------------
app.use('/api/tasks*', authMiddleware);
app.use('/api/submissions*', authMiddleware);

// -------------------------------------------------------------
// POST: Guru Tambah Tugas Baru (hanya role 'guru')
// -------------------------------------------------------------
app.post('/api/tasks', requireRole('guru'), async (c) => {
  const db = getDb();
  const { classId, description, startDate, endDate, attachmentUrl } = await c.req.json();

  try {
    // guruId diambil dari token, bukan dari body — mencegah pemalsuan
    const guruId = c.get('user').id;

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
// POST: Siswa Submit Tugas (hanya role 'siswa')
// -------------------------------------------------------------
app.post('/api/submissions', requireRole('siswa'), async (c) => {
  const db = getDb();
  const { taskId, submitUrl, notes } = await c.req.json();

  try {
    // siswaId diambil dari token, bukan dari body — mencegah pemalsuan
    const siswaId = c.get('user').id;

    const newSubmission = await db.insert(submissions).values({
      taskId,
      siswaId,
      submitUrl,
      notes: notes || null,
    }).returning();

    return c.json({ success: true, data: newSubmission[0] }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

export default app;
