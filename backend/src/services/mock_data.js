function hashCode(s) {
  let h = 0;
  for (let i = 0; i < s.length; i += 1) {
    h = (Math.imul(31, h) + s.charCodeAt(i)) | 0;
  }
  return h;
}

const recipeBank = [
  {
    title: 'One-Pan Roast Chicken & Veggies',
    tagline: 'A perfectly balanced nutrient-dense meal.',
    difficulty: 'intermediate',
    minutes: 35,
    featured: false,
    heroImageQuery: 'roast chicken pan vegetables',
  },
  {
    title: 'Spinach & Hummus Power Bowl',
    tagline: 'Ready in under 15 — great for lunch.',
    difficulty: 'beginner',
    minutes: 15,
    featured: false,
    heroImageQuery: 'spinach hummus bowl',
  },
  {
    title: 'Spicy Pepper Arrabbiata',
    tagline: 'Pasta with a punch, for expiring peppers.',
    difficulty: 'pro',
    minutes: 25,
    featured: false,
    heroImageQuery: 'spicy arrabbiata pasta',
  },
  {
    title: 'Quinoa Stuffed Peppers',
    tagline: 'Colorful, satisfying, and freezer-friendly.',
    difficulty: 'intermediate',
    minutes: 45,
    featured: true,
    heroImageQuery: 'quinoa stuffed peppers',
  },
  {
    title: 'Farm-Egg Shakshuka',
    tagline: 'Eggs poached in a spiced tomato bath.',
    difficulty: 'beginner',
    minutes: 20,
    featured: false,
    heroImageQuery: 'shakshuka eggs skillet',
  },
];

export function mockRecipes(ingredients, count) {
  const seed = hashCode((ingredients || []).join(','));
  const shuffled = [...recipeBank].sort((a, b) => {
    return ((hashCode(a.title) + seed) % 97) - ((hashCode(b.title) + seed) % 97);
  });
  return shuffled.slice(0, count).map((r, idx) => ({
    id: `${hashCode(r.title + seed).toString(36)}${idx}`,
    ...r,
    usesIngredients: (ingredients || []).slice(0, Math.max(1, Math.floor((ingredients?.length ?? 1) * 0.6))),
    coverage: ingredients?.length ? 0.6 : 0,
  }));
}

const fridgeBank = [
  { name: 'Whole Milk', category: 'dairy', quantity: '450 ml', confidence: 0.92 },
  { name: 'Farm Eggs', category: 'protein', quantity: '6 large eggs', confidence: 0.95 },
  { name: 'Chicken Breast', category: 'protein', quantity: '2 servings', confidence: 0.88 },
  { name: 'Half Onion', category: 'vegetables', quantity: null, confidence: 0.82 },
  { name: 'Organic Spinach', category: 'vegetables', quantity: '1 bunch', confidence: 0.91 },
];

const receiptBank = [
  { name: 'Organic Spinach', category: 'vegetables', quantity: '200g', confidence: 0.94 },
  { name: 'Bell Peppers', category: 'vegetables', quantity: '3 ct', confidence: 0.9 },
  { name: 'Cherry Tomato', category: 'vegetables', quantity: '1 pint', confidence: 0.87 },
  { name: 'Farm Eggs', category: 'protein', quantity: '12 ct', confidence: 0.96 },
  { name: 'Whole Milk', category: 'dairy', quantity: '1 L', confidence: 0.89 },
  { name: 'Roma Tomato', category: 'vegetables', quantity: '4 ct', confidence: 0.84 },
  { name: 'Chicken Breast', category: 'protein', quantity: '500g', confidence: 0.93 },
];

export function mockScan(mode) {
  return mode === 'receipt' ? receiptBank : fridgeBank;
}
