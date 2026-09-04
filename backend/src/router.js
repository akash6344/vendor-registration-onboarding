import { createReadStream, existsSync } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { json, parseBody } from './http.js';
import { requireVendor } from './session.js';
import { readDb, writeDb } from './store.js';
import { blankVendor, dashboard, makeId } from './vendor.js';

const rootDir = dirname(dirname(fileURLToPath(import.meta.url)));
const uploadsDir = join(rootDir, 'uploads');
const devOtp = '123456';
const otpTtlMs = 5 * 60 * 1000;

const mimeByExt = {
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.webp': 'image/webp',
  '.gif': 'image/gif',
  '.pdf': 'application/pdf',
  '.mp4': 'video/mp4',
  '.mov': 'video/quicktime',
};

export async function handleRequest(req, res) {
  if (req.method === 'OPTIONS') return json(res, 200, {});

  const url = new URL(req.url, `http://${req.headers.host}`);
  const path = url.pathname;

  try {
    if (req.method === 'GET' && path === '/health') return json(res, 200, { ok: true });
    if (req.method === 'GET' && path.startsWith('/uploads/')) return serveUpload(path, res);
    if (req.method === 'POST' && path === '/auth/send-otp') return sendOtp(req, res);
    if (req.method === 'POST' && path === '/auth/verify-otp') return verifyOtp(req, res);
    if (req.method === 'GET' && path === '/categories') return listCategories(res);
    if (req.method === 'GET' && path === '/subscription-plans') return listPlans(res);
    if (req.method === 'GET' && path === '/addresses/search') return searchAddresses(url, res);
    if (path.startsWith('/vendors/me')) return vendorRoute(req, res, path);
    return json(res, 404, { error: 'Not found' });
  } catch (error) {
    return json(res, 500, { error: error.message || 'Server error' });
  }
}

async function serveUpload(path, res) {
  const relative = path.replace(/^\/uploads\//, '');
  if (!relative || relative.includes('..') || relative.includes('\\')) {
    return json(res, 400, { error: 'Invalid path' });
  }
  const absolute = join(uploadsDir, relative);
  if (!absolute.startsWith(uploadsDir) || !existsSync(absolute)) {
    return json(res, 404, { error: 'File not found' });
  }
  const ext = extname(absolute).toLowerCase();
  const contentType = mimeByExt[ext] || 'application/octet-stream';
  const stream = createReadStream(absolute);
  res.writeHead(200, {
    'content-type': contentType,
    'access-control-allow-origin': '*',
  });
  stream.pipe(res);
}

async function sendOtp(req, res) {
  const { contact } = await parseBody(req);
  if (!contact || !String(contact).trim()) return json(res, 400, { error: 'Contact is required' });

  const db = await readDb();
  db.otps[contact] = { otp: devOtp, expiresAt: Date.now() + otpTtlMs, attempts: 0 };
  await writeDb(db);

  return json(res, 200, {
    message: 'OTP sent',
    devOtp,
    expiresInSeconds: 300,
    resendAfterSeconds: 60,
  });
}

async function verifyOtp(req, res) {
  const { contact, otp } = await parseBody(req);
  const db = await readDb();
  const record = db.otps[contact];

  if (!record) return json(res, 400, { error: 'OTP not requested' });
  if (record.expiresAt < Date.now()) return json(res, 400, { error: 'OTP expired' });
  if (record.attempts >= 5) return json(res, 429, { error: 'Maximum attempts reached' });

  record.attempts += 1;
  if (otp !== record.otp) {
    await writeDb(db);
    return json(res, 400, { error: 'Invalid OTP', attemptsLeft: 5 - record.attempts });
  }

  const token = makeId('session');
  db.sessions[token] = contact;
  db.vendors[contact] ||= blankVendor(contact);
  delete db.otps[contact];
  await writeDb(db);

  return json(res, 200, { token, vendor: db.vendors[contact] });
}

async function listCategories(res) {
  const db = await readDb();
  return json(res, 200, { categories: db.categories });
}

async function listPlans(res) {
  const db = await readDb();
  return json(res, 200, { plans: db.plans.filter((plan) => plan.active) });
}

async function searchAddresses(url, res) {
  const db = await readDb();
  const query = (url.searchParams.get('q') || '').toLowerCase();
  const addresses = db.addresses.filter((item) => JSON.stringify(item).toLowerCase().includes(query));
  return json(res, 200, { addresses });
}

async function vendorRoute(req, res, path) {
  const { db, contact, vendor } = await requireVendor(req);
  if (!vendor) return json(res, 401, { error: 'Unauthorized' });

  if (req.method === 'GET' && path === '/vendors/me') return json(res, 200, { vendor });
  if (req.method === 'PUT' && path === '/vendors/me/onboarding') return saveOnboarding(req, res, db, contact, vendor);
  if (req.method === 'POST' && path === '/vendors/me/uploads') return uploadFile(req, res, vendor);
  if (req.method === 'POST' && path === '/vendors/me/verification/submit') return submitVerification(res, db, vendor);
  if (req.method === 'POST' && path === '/vendors/me/payments/mock') return mockPayment(req, res, db, vendor);
  if (req.method === 'GET' && path === '/vendors/me/dashboard') return json(res, 200, { dashboard: dashboard(vendor, db) });

  return json(res, 404, { error: 'Not found' });
}

async function uploadFile(req, res, vendor) {
  const body = await parseBody(req);
  const { fileName, mimeType, dataBase64 } = body;
  if (!fileName || !dataBase64) return json(res, 400, { error: 'fileName and dataBase64 are required' });

  const safeName = basename(String(fileName)).replace(/[^a-zA-Z0-9._-]/g, '_');
  if (!safeName) return json(res, 400, { error: 'Invalid file name' });

  const vendorFolder = join(uploadsDir, vendor.id);
  await mkdir(vendorFolder, { recursive: true });

  const storedName = `${makeId('file')}-${safeName}`;
  const absolute = join(vendorFolder, storedName);
  const buffer = Buffer.from(String(dataBase64), 'base64');
  if (!buffer.length) return json(res, 400, { error: 'Empty file' });
  if (buffer.length > 10_000_000) return json(res, 400, { error: 'File too large (max 10MB)' });

  await writeFile(absolute, buffer);

  const relativePath = `${vendor.id}/${storedName}`;
  return json(res, 200, {
    fileName: safeName,
    storedPath: relativePath,
    url: `/uploads/${relativePath}`,
    mimeType: mimeType || mimeByExt[extname(safeName).toLowerCase()] || 'application/octet-stream',
    size: buffer.length,
  });
}

async function saveOnboarding(req, res, db, contact, vendor) {
  if (vendor.accountStatus === 'ACTIVE') return json(res, 409, { error: 'Vendor is already active' });
  const patch = await parseBody(req);
  db.vendors[contact] = {
    ...vendor,
    ...patch,
    updatedAt: new Date().toISOString(),
  };
  await writeDb(db);
  return json(res, 200, { vendor: db.vendors[contact] });
}

async function submitVerification(res, db, vendor) {
  vendor.verification.status = 'VERIFIED';
  vendor.currentStep = 'SUBSCRIPTION';
  vendor.updatedAt = new Date().toISOString();
  await writeDb(db);
  return json(res, 200, { vendor });
}

async function mockPayment(req, res, db, vendor) {
  const { planId } = await parseBody(req);
  const plan = db.plans.find((item) => item.id === planId && item.active);
  if (!plan) return json(res, 400, { error: 'Invalid plan' });

  const paidAt = new Date();
  const validUntil = new Date(paidAt.getTime() + plan.durationDays * 86400000).toISOString();
  const payment = {
    id: makeId('pay'),
    vendorId: vendor.id,
    planId,
    amount: plan.price,
    status: 'SUCCESS',
    paidAt: paidAt.toISOString(),
  };

  db.payments.push(payment);
  vendor.subscription = { planId, status: 'ACTIVE', startedAt: paidAt.toISOString(), validUntil };
  vendor.accountStatus = 'ACTIVE';
  vendor.onboardingStatus = 'COMPLETED';
  vendor.currentStep = 'DASHBOARD';
  vendor.updatedAt = new Date().toISOString();
  await writeDb(db);

  return json(res, 200, { payment, vendor, dashboard: dashboard(vendor, db) });
}
