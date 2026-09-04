import { handleRequest } from '../src/router.js';

export default async function handler(req, res) {
  await handleRequest(req, res);
}
