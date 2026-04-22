import OpenAI from 'openai';

const apiKey = process.env.OPENAI_API_KEY;
const textModel = process.env.OPENAI_TEXT_MODEL || 'gpt-4o-mini';
const visionModel = process.env.OPENAI_VISION_MODEL || 'gpt-4o-mini';

export const aiEnabled = Boolean(apiKey);

const client = aiEnabled ? new OpenAI({ apiKey }) : null;

export const MODELS = { text: textModel, vision: visionModel };

/**
 * Call the text model and force a JSON response. Returns the parsed object,
 * or null if the response is not valid JSON.
 */
export async function callTextJson({ system, user, maxTokens = 2400 }) {
  if (!client) {
    const err = new Error('OpenAI API key not configured.');
    err.status = 503;
    err.code = 'openai_disabled';
    throw err;
  }
  const res = await client.chat.completions.create({
    model: textModel,
    max_tokens: maxTokens,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: system },
      { role: 'user', content: user },
    ],
  });
  const text = res.choices?.[0]?.message?.content ?? '';
  return safeParseJson(text);
}

/**
 * Call the vision model with a single image + instruction. Returns the
 * parsed JSON object, or null if the response is not valid JSON.
 */
export async function callVisionJson({
  system,
  instruction,
  imageBuffer,
  mimeType,
  maxTokens = 2000,
}) {
  if (!client) {
    const err = new Error('OpenAI API key not configured.');
    err.status = 503;
    err.code = 'openai_disabled';
    throw err;
  }
  const b64 = imageBuffer.toString('base64');
  const dataUrl = `data:${mimeType || 'image/jpeg'};base64,${b64}`;

  const res = await client.chat.completions.create({
    model: visionModel,
    max_tokens: maxTokens,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: system },
      {
        role: 'user',
        content: [
          { type: 'text', text: instruction },
          { type: 'image_url', image_url: { url: dataUrl } },
        ],
      },
    ],
  });
  const text = res.choices?.[0]?.message?.content ?? '';
  return safeParseJson(text);
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
