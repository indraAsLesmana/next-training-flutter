# Session 3: Neon Database & Backend

## Durasi: 4 jam

## Objectives
- Memahami konsep Database Serverless (Neon)
- Melakukan setup PostgreSQL di Neon
- Membuat schema database
- Membuat Backend API sederhana dengan Node.js/Express
- Menghubungkan Backend ke Neon Database

## Agenda
1. Pengenalan Serverless Database & Neon (45 menit)
2. Setup Neon & SQL Basics (45 menit)
3. Pengenalan Node.js & Express (60 menit)
4. Integrasi Backend ke Neon (90 menit)

## 1. Pengenalan Serverless Database & Neon

### Konsep Serverless Database
- Tidak perlu manage server secara manual
- Auto-scaling berdasarkan beban
- Memisahkan storage dan compute
- Cocok untuk modern applications dan teaching (free tier)

### Mengapa Neon?
- Berbasis PostgreSQL (relational database standar industri)
- Gratis (Free tier cukup untuk training)
- Fitur branching (seperti Git untuk database)
- Dashboard yang mudah digunakan

## 2. Setup Neon & SQL Basics

### Langkah Setup Neon
1. Buka [neon.tech](https://neon.tech)
2. Login dengan akun Google/GitHub
3. Buat Project baru:
   - Name: `todo_app_db`
   - Postgres version: 15 (atau terbaru)
   - Region: Singapore (terdekat)
4. Copy **Connection String** dari dashboard.

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

## 3. Pengenalan Node.js & Express

Sebagai jembatan antara Flutter dan Neon, kita membutuhkan Backend API. Kita akan menggunakan Node.js (Express).

### Setup Project Backend
Buka terminal/command prompt:
```bash
# Buat folder backend
mkdir todo_backend
cd todo_backend

# Inisialisasi npm
npm init -y

# Install dependencies
npm install express pg cors dotenv
```
- `express`: Framework untuk membuat API
- `pg`: PostgreSQL client untuk Node.js
- `cors`: Mengizinkan request dari Flutter
- `dotenv`: Untuk manage environment variables

### Membuat File Server Dasar
Buat file `server.js`:
```javascript
const express = require('express');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json()); // Untuk parsing JSON body

// Basic Route Test
app.get('/', (req, res) => {
  res.json({ message: 'API is working!' });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
```
Jalankan dengan: `node server.js`

## 4. Integrasi Backend ke Neon (CRUD API)

### Setup Koneksi Database
Buat file `.env` (jangan di-commit ke Git):
```env
# Ganti dengan connection string dari Neon Dashboard
DATABASE_URL=postgres://username:password@ep-cool-sun-1234.ap-southeast-1.aws.neon.tech/neondb?sslmode=require
```

### Implementasi Full CRUD di server.js
Update `server.js` menjadi:

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Neon Database Connection
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Verifikasi koneksi
pool.connect()
  .then(() => console.log('Connected to Neon Database!'))
  .catch(err => console.error('Connection error', err.stack));

// --- API ROUTES ---

// 1. GET: Read all tasks
app.get('/tasks', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tasks ORDER BY created_at DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. POST: Create new task
app.post('/tasks', async (req, res) => {
  const { title, description } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO tasks (title, description) VALUES ($1, $2) RETURNING *',
      [title, description || '']
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. PUT: Update task status
app.put('/tasks/:id', async (req, res) => {
  const { id } = req.params;
  const { completed } = req.body;
  
  try {
    const result = await pool.query(
      'UPDATE tasks SET completed = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [completed, id]
    );
    
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 4. DELETE: Remove task
app.delete('/tasks/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('DELETE FROM tasks WHERE id = $1 RETURNING id', [id]);
    
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Task not found' });
    }
    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start Server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
```

### Testing API (Postman / REST Client)
1. Buka Postman / ekstensi REST Client di VS Code
2. Test GET request ke `http://localhost:3000/tasks`
3. Pastikan data dummy dari Neon muncul sebagai JSON.

## Tugas/Latihan Sesi 3
1. Coba jalankan `node server.js` dan pastikan koneksi Neon sukses (Connection to Neon Database!).
2. Gunakan Postman untuk melakukan POST request (membuat Task baru).
3. Cek SQL Editor di Neon Dashboard, verifikasi data baru masuk ke tabel `tasks`.