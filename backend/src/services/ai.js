import * as openai from './openai.js';
import * as gemini from './gemini.js';

export const aiEnabled = openai.aiEnabled || gemini.geminiEnabled;

function isFallbackError(err) {
  // OpenAI quota, rate limit, auth, or service issues → try Gemini.
  const status = err?.status ?? err?.response?.status;
  const code = err?.code;
  return (
    status === 429 ||
    status === 401 ||
    status === 403 ||
    status >= 500 ||
    code === 'insufficient_quota' ||
    code === 'openai_disabled'
  );
}

async function withFallback(name, args) {
  if (openai.aiEnabled) {
    try {
      return await openai[name](args);
    } catch (err) {
      if (!gemini.geminiEnabled || !isFallbackError(err)) throw err;
      // eslint-disable-next-line no-console
      console.warn(
        `[ai] openai.${name} failed (${err.status ?? err.code ?? 'error'}): falling back to gemini`,
      );
    }
  }
  return gemini[name](args);
}

export const callTextJson = (args) => withFallback('callTextJson', args);
export const callVisionJson = (args) => withFallback('callVisionJson', args);
