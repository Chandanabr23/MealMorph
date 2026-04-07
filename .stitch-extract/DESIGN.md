# Design System Strategy: The Digital Greenhouse

## 1. Overview & Creative North Star
The "Digital Greenhouse" is the creative North Star of this design system. We are moving away from the "utility-first" feel of standard food apps and toward a "High-End Editorial" experience. The goal is to make the user feel like they are flipping through a premium culinary magazine that has come to life.

To break the "template" look, we utilize **Intentional Asymmetry**. Large-scale food imagery should often bleed off the edge of the viewport, while typography follows a strict high-contrast scale—pairing massive, confident headers with delicate, airy body copy. We don't just "list" recipes; we curate them on layered surfaces that mimic the organic stacking of fresh ingredients.

---

## 2. Colors & Surface Philosophy
Our palette is rooted in the vitality of nature. We use `primary` (#006E1C) as our anchor and `secondary_container` (#FF9800) as our culinary spark.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders for sectioning content. Boundaries must be defined solely through background color shifts. To separate a recipe card from a category list, place a `surface_container_lowest` card atop a `surface_container_low` background.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical, organic layers.
*   **Base:** `surface` (#FCF9F8) – The foundation.
*   **Mid-Level:** `surface_container_low` – Used for large grouping areas.
*   **Top-Level:** `surface_container_lowest` (#FFFFFF) – Used for the most interactive elements (cards/inputs) to create a "lifted" feel.

### The "Glass & Gradient" Rule
To add "soul," avoid flat blocks of color. Use subtle linear gradients for primary CTAs (transitioning from `primary` to `primary_container`). For floating navigation bars or recipe overlays, apply **Glassmorphism**: use a semi-transparent `surface` color with a `20px` backdrop-blur to allow the vibrant food photography to glow through the UI.

---

## 3. Typography
We use a dual-typeface system to balance professional authority with a welcoming, rounded personality.

*   **Display & Headlines (`plusJakartaSans`):** These are our "editorial" voices. Use `display-lg` for hero recipe titles. The tight kerning and modern curves of Plus Jakarta Sans provide a high-end, bespoke feel.
*   **Titles & Body (`beVietnamPro`):** Selected for its exceptional legibility and soft, rounded terminals. It feels approachable and "human." 
*   **Hierarchy Tip:** Always maintain at least a 2-step jump in the type scale between headers and body copy (e.g., `headline-lg` paired with `body-md`) to ensure the layout feels "designed" rather than "templated."

---

## 4. Elevation & Depth
In this design system, depth is a feeling, not a structure.

*   **Tonal Layering:** Avoid shadows for static elements. Use the difference between `surface_container` tiers to create a natural, soft lift.
*   **Ambient Shadows:** For floating action buttons or active modal states, use extra-diffused shadows. 
    *   *Spec:* `Y: 12px, Blur: 24px, Color: On-Surface (1b1c1c) at 6% opacity.` 
    *   The shadow should feel like a soft glow of light, not a dark smudge.
*   **The "Ghost Border" Fallback:** If a container requires definition against a complex image, use `outline_variant` at **15% opacity**. Never use 100% opaque lines.

---

## 5. Components

### Cards & Lists
*   **Rule:** Forbid the use of divider lines. 
*   **Execution:** Use `spacing-lg` (2rem) between list items. For recipe cards, use a `xl` (3rem) corner radius on the top-left and bottom-right corners only to create a signature, organic "leaf" shape.

### Buttons
*   **Primary:** Uses a gradient of `primary` to `primary_container`. Shape: `full` (pill-shaped). 
*   **Secondary:** `secondary_fixed` background with `on_secondary_fixed` text. No border.
*   **Tertiary:** Transparent background with `primary` text. Use only for low-emphasis actions like "Cancel."

### Input Fields
*   **Styling:** Background set to `surface_container_high`. Corner radius: `md` (1.5rem). 
*   **Focus State:** Transition the background to `surface_container_lowest` and apply a subtle `primary` "Ghost Border" (20% opacity).

### Signature Component: The "Ingredient Float"
*   A horizontally scrolling list of ingredients using selection chips with a `surface_container_lowest` fill. When selected, the chip transforms into a `primary_container` fill with a `sm` ambient shadow.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical margins. For example, give a header a larger left margin than the body text to create an editorial "ragged" look.
*   **Do** use high-quality, "macro" food photography. Zoom in on textures (bubbles in sauce, grains of salt) to make the app feel appetizing.
*   **Do** embrace white space. If you think there is enough space, add 20% more.

### Don’t:
*   **Don’t** use pure black (#000000). Always use `on_surface` (Deep Charcoal) for text to maintain a premium, soft feel.
*   **Don’t** use standard "drop shadows" with high opacity. They make the UI look dated and "heavy."
*   **Don’t** use 90-degree sharp corners. Everything in the kitchen is organic; our UI should reflect that with `md` to `xl` radii.

---

**Director’s Final Note:** 
This design system is about the *space between the elements* as much as the elements themselves. Keep it breathing, keep it vibrant, and let the food be the hero.