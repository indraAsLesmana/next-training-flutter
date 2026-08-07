import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes } from './schema';
import { config as loadEnv } from 'dotenv';
import { parseEnv } from '@neon/env';
import neonConfig from '../../neon';
import { resetDatabase } from './reset';

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
}

seed();