import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import recipesRouter from './routes/recipes.js';
import scanRouter from './routes/scan.js';
import catalogRouter from './routes/catalog.js';

const app = express();
app.use(cors());
app.use(express.json({ limit: '15mb' }));

app.get('/health', (_req, res) => {
  res.json({ ok: true, service: 'mealmorph-backend', ts: Date.now() });
});

app.use('/api/recipes', recipesRouter);
app.use('/api/scan', scanRouter);
app.use('/api/catalog', catalogRouter);

app.use((err, _req, res, _next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: err.code || 'internal_error',
    message: err.message || 'Something went wrong.',
  });
});

const port = Number(process.env.PORT) || 8787;
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`mealmorph-backend listening on :${port}`);
});
