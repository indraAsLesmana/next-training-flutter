# Session 3: Neon Database & API Functions

## Durasi: 4 jam

## Objectives
- Memahami konsep Serverless Database dan API Serverless (Neon Functions)
- Melakukan setup PostgreSQL di Neon
- Membuat schema database
- Membuat Serverless API langsung dari Neon Dashboard
- Menguji API menggunakan Postman atau HTTP Client

## Agenda
1. Pengenalan Serverless Database & Neon (45 menit)
2. Setup Neon & SQL Basics (45 menit)
3. Pengenalan Neon Functions (30 menit)
4. Membuat HTTP Functions (120 menit)

## 1. Pengenalan Serverless Database & Neon

### Konsep Serverless Database
- Tidak perlu manage server secara manual
- Auto-scaling berdasarkan beban
- Memisahkan storage dan compute
- Sangat efisien dan mudah dikelola (cocok untuk environment pembelajaran)

### Mengapa Neon?
- Berbasis PostgreSQL (relational database standar industri)
- Gratis (Free tier cukup untuk training)
- Fitur branching (seperti Git untuk database)
- **Neon Functions**: Menjalankan logika backend API langsung di platform yang sama dengan database, menghasilkan akses data dengan *latency* nyaris nol.

## 2. Setup Neon & SQL Basics

### Langkah Setup Neon
1. Buka [neon.tech](https://neon.tech)
2. Login dengan akun Google/GitHub
3. Buat Project baru:
   - Name: `tugas_db`
   - Postgres version: 15 (atau terbaru)
   - Region: Singapore (terdekat)
4. Masuk ke dashboard project Anda.

### Membuat Schema Database
Di dashboard Neon, buka menu **SQL Editor** dan jalankan:

```sql
-- 1. Buat Table Tasks
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Insert Dummy Data
INSERT INTO tasks (title, description) VALUES 
('Belajar Flutter', 'Sesi 1-4 training'),
('Setup Neon', 'Membuat database cloud');

-- 3. Verifikasi Data (Read)
SELECT * FROM tasks;
```

## 3. Pengenalan Neon Functions

Sebagai jembatan antara Flutter dan Database, kita membutuhkan Backend API. Alih-alih membuat server terpisah (seperti Node.js atau Python server), kita akan menggunakan **Neon Functions**.

### Apa itu Neon Functions?
Neon Functions adalah layanan *serverless compute* dari Neon yang memungkinkan kita menjalankan kode JavaScript/TypeScript langsung pada database branch yang sama. 
- Tidak perlu setup server atau hosting eksternal.
- Connection string otomatis dikelola secara internal.
- *Zero Latency* karena kode berjalan di infrastruktur yang sama dengan database.

## 4. Membuat HTTP Functions (CRUD API)

Kita akan membuat API endpoint yang menangani method GET, POST, PUT, dan DELETE.

1. Di Dashboard Neon, buka menu **Functions**.
2. Klik **Create Function** atau **New Function**.
3. Beri nama function Anda, misalnya `tasks`.
4. Pilih template **HTTP Handler** (JavaScript/TypeScript).
5. Neon akan otomatis menyediakan editor kode. Ganti kode di dalamnya dengan kode berikut:

```javascript
import { neon } from '@neondatabase/serverless';

export default async function (req, ctx) {
  // Database connection secara otomatis menggunakan DATABASE_URL dari branch
  const sql = neon(process.env.DATABASE_URL);
  const { method } = req;
  const url = new URL(req.url);
  const pathParts = url.pathname.split('/').filter(Boolean);

  try {
    // 1. GET Request (Read All)
    if (method === 'GET' && pathParts.length === 0) {
      const result = await sql`SELECT * FROM tasks ORDER BY created_at DESC`;
      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 2. POST Request (Create)
    if (method === 'POST') {
      const body = await req.json();
      const { title, description } = body;
      
      const result = await sql`
        INSERT INTO tasks (title, description) 
        VALUES (${title}, ${description || ''}) 
        RETURNING *
      `;
      return new Response(JSON.stringify(result[0]), {
        status: 201,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Ambil ID dari path: /tasks/123 -> id = 123
    const id = pathParts[0];

    // 3. PUT Request (Update Status)
    if (method === 'PUT' && id) {
      const body = await req.json();
      const { completed } = body;
      
      const result = await sql`
        UPDATE tasks 
        SET completed = ${completed}, updated_at = CURRENT_TIMESTAMP 
        WHERE id = ${id} 
        RETURNING *
      `;
      
      if (result.length === 0) {
        return new Response(JSON.stringify({ message: 'Task not found' }), { status: 404 });
      }
      return new Response(JSON.stringify(result[0]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // 4. DELETE Request (Remove)
    if (method === 'DELETE' && id) {
      const result = await sql`DELETE FROM tasks WHERE id = ${id} RETURNING id`;
      
      if (result.length === 0) {
        return new Response(JSON.stringify({ message: 'Task not found' }), { status: 404 });
      }
      return new Response(JSON.stringify({ message: 'Task deleted successfully' }), { status: 200 });
    }

    // Fallback jika route tidak ditemukan
    return new Response('Not Found', { status: 404 });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
}
```

6. Simpan / Deploy kode tersebut.
7. Neon akan memberikan URL endpoint publik untuk function ini (contoh: `https://ep-name-1234.neon.build/tasks`). 
8. **Catat URL dasar (Base URL) ini tanpa path `/tasks`!** (contoh: `https://ep-name-1234.neon.build`). URL ini akan kita masukkan ke `config.json` di aplikasi Flutter kita pada sesi selanjutnya.

### Testing API (Postman / REST Client)
1. Buka Postman atau ekstensi REST Client di VS Code.
2. Lakukan test GET request ke URL endpoint lengkap yang baru saja dibuat.
3. Pastikan data dummy yang Anda inputkan di SQL Editor muncul sebagai response JSON.

## Tugas/Latihan Sesi 3
1. Pastikan Anda bisa mengakses endpoint Function Anda dan tidak mendapatkan error CORS/Connection (secara default Neon HTTP functions mengizinkan request API).
2. Gunakan Postman untuk melakukan POST request (membuat Task baru).
3. Cek kembali SQL Editor di Neon Dashboard (`SELECT * FROM tasks;`), verifikasi data baru benar-benar masuk ke database.