import { GoogleGenerativeAI } from '@google/generative-ai';

const apiKey = process.env.GEMINI_API_KEY;
const textModel = process.env.GEMINI_TEXT_MODEL || 'gemini-2.5-flash';
const visionModel = process.env.GEMINI_VISION_MODEL || 'gemini-2.5-flash';

export const geminiEnabled = Boolean(apiKey);

const client = geminiEnabled ? new GoogleGenerativeAI(apiKey) : null;

export async function callTextJson({ system, user, maxTokens = 2400 }) {
  if (!client) {
    const err = new Error('Gemini API key not configured.');
    err.status = 503;
    err.code = 'gemini_disabled';
    throw err;
  }
  const model = client.getGenerativeModel({
    model: textModel,
    systemInstruction: system,
    generationConfig: {
      maxOutputTokens: maxTokens,
      responseMimeType: 'application/json',
    },
  });
  const res = await model.generateContent(user);
  return safeParseJson(res.response.text());
}

export async function callVisionJson({
  system,
  instruction,
  imageBuffer,
  mimeType,
  maxTokens = 2000,
}) {
  if (!client) {
    const err = new Error('Gemini API key not configured.');
    err.status = 503;
    err.code = 'gemini_disabled';
    throw err;
  }
  const model = client.getGenerativeModel({
    model: visionModel,
    systemInstruction: system,
    generationConfig: {
      maxOutputTokens: maxTokens,
      responseMimeType: 'application/json',
    },
  });
  const safeMime = mimeType && mimeType.startsWith('image/')
    ? mimeType
    : 'image/jpeg';
  const res = await model.generateContent([
    {
      inlineData: {
        mimeType: safeMime,
        data: imageBuffer.toString('base64'),
      },
    },
    { text: instruction },
  ]);
  return safeParseJson(res.response.text());
}

function safeParseJson(text) {
  if (!text) return null;
  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  const candidate = fenced ? fenced[1] : text;
  try {
    return JSON.parse(candidate.trim());
  } catch {
    return null;
  }
}
