require('dotenv').config();
const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const projectRoot = path.resolve(rootDir, '..');
const envPath = path.join(rootDir, '.env');
const envExamplePath = path.join(rootDir, '.env.example');

function run(command, args, options = {}) {
  console.log(`\n> ${command} ${args.join(' ')}`);
  execFileSync(command, args, {
    cwd: options.cwd || rootDir,
    stdio: 'inherit',
    shell: process.platform === 'win32',
    env: process.env,
  });
}

function ensureEnv() {
  if (!fs.existsSync(envPath)) {
    fs.copyFileSync(envExamplePath, envPath);
    console.log('[OK] Created backend/.env from backend/.env.example');
  } else {
    console.log('[OK] backend/.env already exists');
  }
}

function startPostgres() {
  const composeFile = path.join(projectRoot, 'docker-compose.yml');
  if (!fs.existsSync(composeFile)) {
    throw new Error(`docker-compose.yml not found at ${composeFile}`);
  }
  run('docker', ['compose', '-f', composeFile, 'up', '-d', 'postgres'], { cwd: projectRoot });
}

function main() {
  ensureEnv();
  startPostgres();
  run('node', ['scripts/wait-for-db.js']);
  run('npx', ['prisma', 'generate']);
  run('npx', ['prisma', 'db', 'push']);
  run('npm', ['run', 'db:seed']);
  console.log('\n[OK] Backend database is ready. Run: npm run dev');
  console.log('[OK] Health check: http://localhost:3000/health/ready');
}

try {
  main();
} catch (error) {
  console.error('\n[ERROR] Setup failed.');
  console.error(error.message || error);
  console.error('\nChecklist:');
  console.error('1. Make sure Docker Desktop is open/running.');
  console.error('2. Run this from the backend folder: npm run setup');
  console.error('3. If port 5432 is busy, stop the other PostgreSQL service or change the mapped port.');
  process.exit(1);
}
