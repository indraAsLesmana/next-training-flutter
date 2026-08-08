import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes, users, tasks, submissions } from './db/schema';
import { eq } from 'drizzle-orm';
import {
  hashPassword,
  comparePassword,
  signToken,
  requireAuth,
  requireRole,
} from './auth';

const app = new Hono();

app.use('*', cors());

// Helper Koneksi Drizzle Client
function getDb() {
  const sql = neon(process.env.DATABASE_URL!);
  return drizzle(sql);
}

// Jangan pernah mengirim passwordHash ke client.
function publicUser(user: any) {
  const { passwordHash, ...rest } = user;
  return rest;
}

// -------------------------------------------------------------
// GET: Master Kelas
// Publik (tanpa auth) agar bisa dipakai saat proses registrasi,
// sebelum user login/mendapat token.
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
// Password di-hash dengan scrypt; response tidak menyertakan hash,
// dan mengembalikan token JWT untuk sesi login langsung.
// -------------------------------------------------------------
app.post('/api/auth/register', async (c) => {
  const db = getDb();
  const { nama, role, nipNik, email, password, classId } = await c.req.json();

  if (!nama || !role || !nipNik || !password) {
    return c.json({ success: false, message: 'Nama, role, NIP/NIK, dan password wajib diisi' }, 400);
  }
  if (role !== 'guru' && role !== 'siswa') {
    return c.json({ success: false, message: 'Role harus guru atau siswa' }, 400);
  }

  try {
    const existing = await db.select().from(users).where(eq(users.nipNik, nipNik));
    if (existing.length > 0) {
      return c.json({ success: false, message: 'NIP/NIK sudah terdaftar' }, 409);
    }

    const passwordHash = await hashPassword(password);
    const [newUser] = await db.insert(users).values({
      nama,
      role,
      nipNik,
      email: email || null,
      passwordHash,
      classId: role === 'guru' ? null : classId,
    }).returning();

    const token = await signToken({ userId: newUser.id, role: newUser.role });
    return c.json({ success: true, data: publicUser(newUser), token }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Login User
// Memverifikasi password (scrypt) dan mengembalikan token JWT.
// -------------------------------------------------------------
app.post('/api/auth/login', async (c) => {
  const db = getDb();
  const { nipNik, password } = await c.req.json();

  if (!nipNik || !password) {
    return c.json({ success: false, message: 'NIP/NIK dan password wajib diisi' }, 400);
  }

  try {
    const foundUsers = await db.select().from(users).where(eq(users.nipNik, nipNik));
    if (foundUsers.length === 0) {
      return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
    }

    const user = foundUsers[0];
    const valid = await comparePassword(password, user.passwordHash);
    if (!valid) {
      return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
    }

    const token = await signToken({ userId: user.id, role: user.role });
    return c.json({ success: true, data: publicUser(user), token }, 200);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Guru Tambah Tugas Baru
// Hanya role guru. `guruId` diambil dari token, bukan dari body request.
// -------------------------------------------------------------
app.post('/api/tasks', requireAuth, requireRole('guru'), async (c) => {
  const db = getDb();
  const { classId, description, startDate, endDate, attachmentUrl } = await c.req.json();
  const guruId = c.get('userId');

  if (!classId || !description || !startDate || !endDate) {
    return c.json({ success: false, message: 'Kelas, deskripsi, dan tanggal wajib diisi' }, 400);
  }

  try {
    const [newTask] = await db.insert(tasks).values({
      guruId,
      classId,
      description,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      attachmentUrl: attachmentUrl || null,
    }).returning();

    return c.json({ success: true, data: newTask }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

// -------------------------------------------------------------
// POST: Siswa Submit Tugas
// Hanya role siswa. `siswaId` diambil dari token, bukan dari body request.
// -------------------------------------------------------------
app.post('/api/submissions', requireAuth, requireRole('siswa'), async (c) => {
  const db = getDb();
  const { taskId, submitUrl, notes } = await c.req.json();
  const siswaId = c.get('userId');

  if (!taskId || !submitUrl) {
    return c.json({ success: false, message: 'Task ID dan URL pengumpulan wajib diisi' }, 400);
  }

  try {
    const [newSubmission] = await db.insert(submissions).values({
      taskId,
      siswaId,
      submitUrl,
      notes: notes || null,
    }).returning();

    return c.json({ success: true, data: newSubmission }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

export default app;
