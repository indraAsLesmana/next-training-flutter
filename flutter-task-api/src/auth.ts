// Helpers autentikasi & otorisasi untuk API.
//
// - Password di-hash dengan scrypt (KDF bawaan Node.js, bukan plaintext).
//   Format hash: scrypt$<salt_hex>$<hash_hex>.
// - Setelah login/register, client mendapat JWT yang harus dikirim
//   pada header `Authorization: Bearer <token>`.
// - `requireAuth` memverifikasi token; `requireRole` memastikan role yang benar.
import { randomBytes, scrypt as _scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { sign, verify } from 'hono/jwt';
import { createMiddleware } from 'hono/factory';

const scrypt = promisify(_scrypt);

// Di produksi, set JWT_SECRET di environment. Jangan gunakan nilai default ini.
const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-me-in-production';
const SALT_BYTES = 16;
const KEY_LENGTH = 64;
const TOKEN_TTL_SECONDS = 60 * 60 * 24 * 7; // 7 hari

export async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(SALT_BYTES);
  const hash = (await scrypt(password, salt, KEY_LENGTH)) as Buffer;
  return `scrypt$${salt.toString('hex')}$${hash.toString('hex')}`;
}

export async function comparePassword(password: string, stored: string): Promise<boolean> {
  const parts = stored.split('$');
  if (parts.length !== 3 || parts[0] !== 'scrypt') {
    return false;
  }
  const salt = Buffer.from(parts[1], 'hex');
  const expected = Buffer.from(parts[2], 'hex');
  const actual = (await scrypt(password, salt, KEY_LENGTH)) as Buffer;
  return actual.length === expected.length && timingSafeEqual(actual, expected);
}

export async function signToken(payload: { userId: string; role: string }): Promise<string> {
  const jwtPayload = {
    ...payload,
    exp: Math.floor(Date.now() / 1000) + TOKEN_TTL_SECONDS,
  };
  return sign(jwtPayload, JWT_SECRET);
}

// Middleware: memastikan request punya token valid, lalu menyimpan
// userId & userRole ke context Hono.
export const requireAuth = createMiddleware(async (c, next) => {
  const header = c.req.header('Authorization');
  if (!header || !header.startsWith('Bearer ')) {
    return c.json({ success: false, message: 'Tidak ada token autentikasi' }, 401);
  }

  const token = header.slice('Bearer '.length);
  try {
    const payload = await verify(token, JWT_SECRET);
    c.set('userId', payload.userId);
    c.set('userRole', payload.role);
    await next();
  } catch {
    return c.json({ success: false, message: 'Token tidak valid atau kedaluwarsa' }, 401);
  }
});

// Middleware: membatasi endpoint untuk role tertentu (mis. 'guru' / 'siswa').
export const requireRole = (role: string) =>
  createMiddleware(async (c, next) => {
    const userRole = c.get('userRole');
    if (userRole !== role) {
      return c.json({ success: false, message: 'Tidak memiliki izin untuk aksi ini' }, 403);
    }
    await next();
  });
