require('dotenv').config();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  console.log('JogjaSplorasi backend doctor');
  console.log('DATABASE_URL:', (process.env.DATABASE_URL || '').replace(/:[^:@/]+@/, ':****@'));
  await prisma.$queryRaw`SELECT 1`;
  const [users, destinations, quizQuestions] = await Promise.all([
    prisma.user.count(),
    prisma.destination.count(),
    prisma.quizQuestion.count(),
  ]);
  console.log('[OK] Database connected');
  console.log(`[OK] users=${users}, destinations=${destinations}, quizQuestions=${quizQuestions}`);
}

main()
  .catch((error) => {
    console.error('[ERROR] Backend is not ready:', error.message);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
