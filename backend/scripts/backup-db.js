const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error('DATABASE_URL is required');
const backupDir = path.resolve(process.env.BACKUP_DIR || './backups');
fs.mkdirSync(backupDir, { recursive: true });
const filename = `jogjasplorasi-${new Date().toISOString().replace(/[:.]/g, '-')}.dump`;
const filepath = path.join(backupDir, filename);
execFileSync('pg_dump', ['--format=custom', '--file', filepath, databaseUrl], { stdio: 'inherit' });
console.log(`Backup created: ${filepath}`);
