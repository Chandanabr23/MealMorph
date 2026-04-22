import { Router } from 'express';
import multer from 'multer';
import { aiEnabled, callVisionJson } from '../services/openai.js';
import { mockScan } from '../services/mock_data.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

const router = Router();

const SYSTEMS = {
  fridge:
    'You identify grocery / fridge ingredients from photos of refrigerators or countertops. Respond with a single JSON object and nothing else.',
  receipt:
    'You parse grocery receipts. Only return food ingredients — ignore totals, taxes, merchant info. Respond with a single JSON object and nothing else.',
};

const INSTRUCTIONS = {
  fridge:
    'Identify every visible ingredient in this photo. Group duplicates. Infer a concise, normalised ingredient name for each.',
  receipt:
    'Extract each food item purchased from this receipt. Infer a concise, normalised ingredient name for each row.',
};

async function analyseImage({ buffer, mimeType, mode }) {
  if (!aiEnabled) {
    return { mode: 'mock', items: mockScan(mode) };
  }
  const system = SYSTEMS[mode] ?? SYSTEMS.fridge;
  const instruction = `${INSTRUCTIONS[mode] ?? INSTRUCTIONS.fridge}

Respond as strict JSON with this shape:
{
  "items": [
    {
      "name": "string",
      "category": "vegetables" | "fruits" | "dairy" | "protein" | "grains" | "condiments" | "other",
      "quantity": "string or null",
      "confidence": 0.0
    }
  ]
}`;

  const parsed = await callVisionJson({
    system,
    instruction,
    imageBuffer: buffer,
    mimeType,
    maxTokens: 2000,
  });
  if (!parsed || !Array.isArray(parsed.items)) {
    return { mode: 'fallback', items: mockScan(mode) };
  }
  return { mode: 'live', items: parsed.items };
}

router.post('/fridge', upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) {
      res
        .status(400)
        .json({ error: 'missing_image', message: 'Attach an image file under "image".' });
      return;
    }
    const result = await analyseImage({
      buffer: req.file.buffer,
      mimeType: req.file.mimetype,
      mode: 'fridge',
    });
    res.json(result);
  } catch (err) {
    next(err);
  }
});

router.post('/receipt', upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) {
      res
        .status(400)
        .json({ error: 'missing_image', message: 'Attach an image file under "image".' });
      return;
    }
    const result = await analyseImage({
      buffer: req.file.buffer,
      mimeType: req.file.mimetype,
      mode: 'receipt',
    });
    res.json(result);
  } catch (err) {
    next(err);
  }
});

export default router;
