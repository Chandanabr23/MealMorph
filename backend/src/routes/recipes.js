import { Router } from 'express';
import { aiEnabled, callTextJson } from '../services/ai.js';
import { mockRecipes } from '../services/mock_data.js';

const router = Router();

router.post('/generate', async (req, res, next) => {
  try {
    const ingredients = Array.isArray(req.body?.ingredients)
      ? req.body.ingredients.map((s) => String(s).trim()).filter(Boolean)
      : [];
    const count = Math.min(Math.max(Number(req.body?.count) || 5, 1), 10);

    if (!aiEnabled) {
      res.json({
        mode: 'mock',
        recipes: mockRecipes(ingredients, count),
      });
      return;
    }

    const system =
      'You are MealMorph, a culinary AI that turns a set of ingredients into inventive, expiry-aware recipes. Respond with a single JSON object and nothing else.';

    const user = `Given these fridge ingredients (with optional "[expiring soon]" hints), return ${count} recipes that prioritise the expiring-soon items first.

Ingredients: ${JSON.stringify(ingredients)}

Respond as strict JSON with this shape:
{
  "recipes": [
    {
      "id": "slug",
      "title": "string",
      "tagline": "short one-line description",
      "difficulty": "beginner" | "intermediate" | "pro",
      "minutes": number,
      "usesIngredients": ["..."],
      "coverage": 0.0,
      "featured": false,
      "heroImageQuery": "terse search query for a cover photo"
    }
  ]
}`;

    const parsed = await callTextJson({ system, user, maxTokens: 2400 });
    if (!parsed || !Array.isArray(parsed.recipes)) {
      res.json({
        mode: 'fallback',
        recipes: mockRecipes(ingredients, count),
      });
      return;
    }
    res.json({ mode: 'live', recipes: parsed.recipes });
  } catch (err) {
    next(err);
  }
});

export default router;
