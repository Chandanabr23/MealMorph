import { Router } from 'express';

const router = Router();

const categories = [
  { id: 'vegetables', label: 'Vegetables', icon: 'leaf' },
  { id: 'dairy', label: 'Dairy', icon: 'dairy' },
  { id: 'protein', label: 'Protein', icon: 'protein' },
  { id: 'fruits', label: 'Fruits', icon: 'fruit' },
  { id: 'grains', label: 'Grains', icon: 'grain' },
  { id: 'condiments', label: 'Condiments', icon: 'sauce' },
];

const commonlyAdded = [
  { id: 'organic-spinach', name: 'Organic Spinach', category: 'vegetables', shelfLifeDays: 5 },
  { id: 'whole-milk', name: 'Whole Milk', category: 'dairy', shelfLifeDays: 7 },
  { id: 'farm-eggs', name: 'Farm Eggs', category: 'protein', shelfLifeDays: 21 },
  { id: 'chicken-breast', name: 'Chicken Breast', category: 'protein', shelfLifeDays: 2 },
  { id: 'half-onion', name: 'Half Onion', category: 'vegetables', shelfLifeDays: 4 },
  { id: 'roma-tomato', name: 'Roma Tomato', category: 'vegetables', shelfLifeDays: 6 },
];

router.get('/categories', (_req, res) => {
  res.json({ categories });
});

router.get('/commonly-added', (_req, res) => {
  res.json({ items: commonlyAdded });
});

export default router;
