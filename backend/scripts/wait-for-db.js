require('dotenv').config();
const net = require('net');

function parseDatabaseUrl(value) {
  try {
    const url = new URL(value);
    return {
      host: url.hostname || 'localhost',
      port: Number(url.port || 5432),
      database: url.pathname.replace(/^\//, '') || 'jogjasplorasi',
    };
  } catch (error) {
    return { host: 'localhost', port: 5432, database: 'jogjasplorasi' };
  }
}

const db = parseDatabaseUrl(process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/jogjasplorasi?schema=public');
const timeoutMs = Number(process.env.DB_WAIT_TIMEOUT_MS || 60000);
const startedAt = Date.now();

function tryConnect() {
  const socket = net.createConnection({ host: db.host, port: db.port });
  socket.setTimeout(2500);

  socket.on('connect', () => {
    socket.destroy();
    console.log(`[OK] PostgreSQL is reachable at ${db.host}:${db.port}/${db.database}`);
    process.exit(0);
  });

  function retry() {
    socket.destroy();
    if (Date.now() - startedAt > timeoutMs) {
      console.error(`[ERROR] PostgreSQL is not reachable at ${db.host}:${db.port}.`);
      console.error('Start it first with: docker compose up -d postgres');
      process.exit(1);
    }
    setTimeout(tryConnect, 1500);
  }

  socket.on('timeout', retry);
  socket.on('error', retry);
}

console.log(`[INFO] Waiting for PostgreSQL at ${db.host}:${db.port}...`);
tryConnect();
