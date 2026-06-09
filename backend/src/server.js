require('dotenv').config();
const app = require('./app');
const prisma = require('./config/prisma');

const port = Number(process.env.PORT || 3000);

async function start() {
  try {
    await prisma.$connect();
    const server = app.listen(port, () => {
      console.log(`JogjaSplorasi API berjalan di http://localhost:${port}`);
    });

    const shutdown = async (signal) => {
      console.log(`${signal} diterima. Menutup server...`);
      server.close(async () => {
        await prisma.$disconnect();
        process.exit(0);
      });
    };

    process.on('SIGINT', () => shutdown('SIGINT'));
    process.on('SIGTERM', () => shutdown('SIGTERM'));
  } catch (error) {
    console.error('Backend gagal berjalan. Periksa DATABASE_URL dan koneksi PostgreSQL.', error);
    await prisma.$disconnect();
    process.exit(1);
  }
}

start();
