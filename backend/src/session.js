import { tokenFrom } from './http.js';
import { readDb } from './store.js';

export async function requireVendor(req) {
  const db = await readDb();
  const token = tokenFrom(req);
  const contact = token ? db.sessions[token] : null;
  const vendor = contact ? db.vendors[contact] : null;
  return { db, token, contact, vendor };
}
