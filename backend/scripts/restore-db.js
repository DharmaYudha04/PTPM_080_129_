const { execFileSync } = require('child_process');
require('dotenv').config();

const databaseUrl = process.env.DATABASE_URL;
const backupFile = process.argv[2];
if (!databaseUrl) throw new Error('DATABASE_URL is required');
if (!backupFile) throw new Error('Usage: npm run restore:db -- ./backups/file.dump');
execFileSync('pg_restore', ['--clean', '--if-exists', '--no-owner', '--dbname', databaseUrl, backupFile], { stdio: 'inherit' });
console.log('Restore completed');
