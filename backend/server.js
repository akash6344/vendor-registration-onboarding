import { createServer } from 'node:http';

import { handleRequest } from './src/router.js';

const port = Number(process.env.PORT || 4000);
const host = process.env.HOST || '0.0.0.0';

createServer(handleRequest).listen(port, host, () => {
  console.log(`Vendor onboarding API listening on http://${host}:${port}`);
});
