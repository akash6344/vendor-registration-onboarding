import { createServer } from 'node:http';

import { handleRequest } from './src/router.js';

const port = Number(process.env.PORT || 4000);

createServer(handleRequest).listen(port, () => {
  console.log(`Vendor onboarding API listening on http://localhost:${port}`);
});
