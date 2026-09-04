import { existsSync } from 'node:fs';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const rootDir = dirname(dirname(fileURLToPath(import.meta.url)));
const isVercel = Boolean(process.env.VERCEL);
const dataDir = isVercel ? '/tmp/vendor-data' : join(rootDir, 'data');
export const uploadsDir = isVercel ? '/tmp/vendor-uploads' : join(rootDir, 'uploads');

const seedPath = join(rootDir, 'data', 'seed.json');
const dbPath = join(dataDir, 'db.json');

export async function readDb() {
  await ensureDb();
  return JSON.parse(await readFile(dbPath, 'utf8'));
}

export async function writeDb(data) {
  await mkdir(dataDir, { recursive: true });
  await writeFile(dbPath, `${JSON.stringify(data, null, 2)}\n`);
}

async function ensureDb() {
  await mkdir(dataDir, { recursive: true });
  await mkdir(uploadsDir, { recursive: true });
  if (!existsSync(dbPath)) {
    const seed = JSON.parse(await readFile(seedPath, 'utf8'));
    await writeDb({
      ...seed,
      otps: {},
      sessions: {},
      vendors: {},
      payments: [],
    });
  }
}
