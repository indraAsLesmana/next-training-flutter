import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import { classes } from './schema';
import { config as loadEnv } from 'dotenv';
import { parseEnv } from '@neon/env';
import neonConfig from '../../neon';

// Load .env.local fallback
loadEnv({ path: '.env.local' });

async function seed() {
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
        // Insert data (abaikan jika ada bentrok/ON CONFLICT)
        await db.insert(classes).values(dataClasses).onConflictDoNothing();
        console.log('✅ Seeding berhasil!');
    } catch (error) {
        console.error('❌ Gagal seeding data:', error);
    }
}

seed();