import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes, users } from './schema';
import { eq } from 'drizzle-orm';
import { config as loadEnv } from 'dotenv';
import { parseEnv } from '@neon/env';
import neonConfig from '../../neon';
import { resetDatabase } from './reset';
import { hashPassword } from '../auth';

loadEnv({ path: '.env.local' });

async function seed() {
    // If --clean or --reset flag is provided, reset all tables first
    if (process.argv.includes('--clean') || process.argv.includes('--reset')) {
        await resetDatabase();
    }

    let databaseUrl: string | undefined;

    try {
        const env = parseEnv(neonConfig);
        databaseUrl = env.postgres.databaseUrl;
    } catch {
        databaseUrl = process.env.DATABASE_URL;
    }

    if (!databaseUrl) {
        throw new Error('DATABASE_URL tidak ditemukan');
    }

    const sql = neon(databaseUrl);
    const db = drizzle(sql);

    console.log('🌱 Memulai seeding data kelas...');

    const dataClasses = [
        { tingkat: 'X', namaKelas: 'a' },
        { tingkat: 'X', namaKelas: 'b' },
        { tingkat: 'X', namaKelas: 'c' },
        { tingkat: 'X', namaKelas: 'd' },
        { tingkat: 'XI', namaKelas: 'a' },
        { tingkat: 'XI', namaKelas: 'b' },
        { tingkat: 'XI', namaKelas: 'c' },
        { tingkat: 'XI', namaKelas: 'd' },
        { tingkat: 'XII', namaKelas: 'a' },
        { tingkat: 'XII', namaKelas: 'b' },
        { tingkat: 'XII', namaKelas: 'c' },
        { tingkat: 'XII', namaKelas: 'd' },
    ];

    try {
        // Safe idempotent insert (on conflict do nothing based on unique constraint)
        const result = await db.insert(classes).values(dataClasses).onConflictDoNothing();
        console.log('✅ Seeding data kelas selesai (idempotent)!');
    } catch (error) {
        console.error('❌ Gagal seeding data:', error);
    }

    // ---------------------------------------------------------
    // Seed akun demo (idempotent) agar aplikasi bisa langsung diuji
    // ---------------------------------------------------------
    console.log('👤 Seeding akun demo...');

    const demoUsers = [
        {
            nama: 'Demo Guru',
            role: 'guru',
            nipNik: 'GURU001',
            email: 'guru@demo.sch.id',
            password: 'demo123',
            classId: null as string | null,
        },
        {
            nama: 'Demo Siswa',
            role: 'siswa',
            nipNik: 'SISWA001',
            email: 'siswa@demo.sch.id',
            password: 'demo123',
            classId: null as string | null,
        },
    ];

    try {
        for (const u of demoUsers) {
            const existing = await db.select().from(users).where(eq(users.nipNik, u.nipNik));
            if (existing.length > 0) {
                console.log(`⏭️  Akun ${u.nipNik} sudah ada, dilewati`);
                continue;
            }
            const passwordHash = await hashPassword(u.password);
            // Siswa demo dihubungkan ke kelas pertama (X a)
            const classForStudent = u.role === 'siswa'
                ? (await db.select().from(classes).limit(1))[0]?.id ?? null
                : null;
            await db.insert(users).values({
                nama: u.nama,
                role: u.role,
                nipNik: u.nipNik,
                email: u.email,
                passwordHash,
                classId: classForStudent,
            });
            console.log(`✅ Akun demo ${u.nipNik} (${u.role}) dibuat`);
        }
    } catch (error) {
        console.error('❌ Gagal seeding akun demo:', error);
    }
}

seed();
