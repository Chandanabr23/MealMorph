# MealMorph Backend

Node.js (Express) service that backs the MealMorph Flutter app with AI features.

## Endpoints

- `GET  /health` — liveness probe.
- `POST /api/recipes/generate` — body `{ ingredients: string[], count?: number }` → `{ mode, recipes[] }`.
- `POST /api/scan/fridge` — multipart `image` → `{ mode, items[] }`.
- `POST /api/scan/receipt` — multipart `image` → `{ mode, items[] }`.
- `GET  /api/catalog/categories` — quick-category chips for Add-to-Fridge.
- `GET  /api/catalog/commonly-added` — user-facing "Commonly Added" list.

When `OPENAI_API_KEY` is unset, the AI endpoints return deterministic mock data
(`mode: "mock"`). With a key, recipes use the text model (default `gpt-4o-mini`)
and scans use the vision model (default `gpt-4o-mini`), returning `mode: "live"`.
If the model returns unparseable output, handlers fall back to `mode: "fallback"`
with mock data.

Override models with `OPENAI_TEXT_MODEL` / `OPENAI_VISION_MODEL` in `.env`.

## Run

```bash
cd backend
cp .env.example .env           # add OPENAI_API_KEY to enable live AI
npm install
npm run dev                    # starts on :8787 (override with PORT)
```

**Never commit `.env`** — it is already listed in `.gitignore`. If an API key
is ever exposed (pasted in chat, pushed to git, shared in a screenshot),
revoke it in the OpenAI dashboard and issue a new one before using it.

The Flutter app reads the base URL from the `MEALMORPH_API_BASE` dart-define
(see `lib/core/config/api_config.dart`). Defaults to `http://10.0.2.2:8787` on
Android emulator and `http://localhost:8787` elsewhere.
