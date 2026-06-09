require('dotenv').config();

const required = ['DATABASE_URL', 'JWT_SECRET'];
const missing = required.filter((key) => !process.env[key] || !String(process.env[key]).trim());

if (missing.length) {
  console.error(`Environment belum lengkap: ${missing.join(', ')}`);
  console.error('Salin backend/.env.example menjadi backend/.env lalu sesuaikan nilainya.');
  process.exit(1);
}

if (process.env.JWT_SECRET.length < 32) {
  console.error('JWT_SECRET minimal 32 karakter agar token aman.');
  process.exit(1);
}

console.log('Environment backend valid.');
