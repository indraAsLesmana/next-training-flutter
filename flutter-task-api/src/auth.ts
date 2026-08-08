import { MiddlewareHandler } from 'hono';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// -------------------------------------------------------------
// Helper autentikasi: hashing password (bcrypt) + JWT
// -------------------------------------------------------------

// Variabel yang disisipkan ke context request oleh middleware auth
export type AuthVariables = {
  user: { id: string; role: string };
};

const JWT_SECRET = process.env.JWT_SECRET || 'dev-insecure-secret-change-in-production';

// Hash password sebelum disimpan ke database
export async function hashPassword(password: string): Promise<string> {
  const saltRounds = 10;
  return bcrypt.hash(password, saltRounds);
}

// Verifikasi password plaintext terhadap hash yang tersimpan
export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}

// Buat token JWT berisi id & role user
export async function signToken(user: { id: string; role: string }): Promise<string> {
  return jwt.sign(
    { sub: user.id, role: user.role },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
}

// Middleware: pastikan request punya Bearer token yang valid
export const authMiddleware: MiddlewareHandler<{ Variables: AuthVariables }> = async (c, next) => {
  const authHeader = c.req.header('Authorization') || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

  if (!token) {
    return c.json({ success: false, message: 'Tidak ada token autentikasi' }, 401);
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as { sub: string; role: string };
    // Simpan user dari token agar bisa dipakai handler berikutnya
    c.set('user', { id: payload.sub, role: payload.role });
    await next();
  } catch (err) {
    return c.json({ success: false, message: 'Token tidak valid atau kedaluwarsa' }, 401);
  }
};

// Middleware: batasi akses hanya untuk role tertentu ('guru' | 'siswa')
export const requireRole = (role: string): MiddlewareHandler<{ Variables: AuthVariables }> => {
  return async (c, next) => {
    const user = c.get('user') as { id: string; role: string } | undefined;
    if (!user) {
      return c.json({ success: false, message: 'Belum terautentikasi' }, 401);
    }
    if (user.role !== role) {
      return c.json({ success: false, message: 'Akses ditolak' }, 403);
    }
    await next();
  };
};
