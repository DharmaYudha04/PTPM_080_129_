const fs = require('fs');
const path = require('path');

const projectRoot = path.resolve(__dirname, '..', '..');
const obsoletePaths = [
  'backend/prisma/quiz_questions.js',
  'backend/scripts/enrich-destination-descriptions.js',
  'build',
  'android/build',
  'android/.gradle',
  '.dart_tool',
  'backend/node_modules',
  'node_modules',
];

for (const relativePath of obsoletePaths) {
  const target = path.join(projectRoot, relativePath);
  if (!fs.existsSync(target)) continue;
  fs.rmSync(target, { recursive: true, force: true });
  console.log(`[OK] removed ${relativePath}`);
}

console.log('[OK] cleanup complete.');
