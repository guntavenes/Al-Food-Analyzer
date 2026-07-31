import { createApp } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const app = createApp(config);
app.listen(config.port, () => {
  process.stdout.write(`AI Food Analyzer backend listening on port ${config.port}\n`);
});
