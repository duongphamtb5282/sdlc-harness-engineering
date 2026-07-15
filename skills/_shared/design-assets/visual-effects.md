<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Visual Effects — Glassmorphism, Shadows, Gradients

> **Optional read** during Phase 5 (Design & Polish). Load when applying visual treatments.

---

## Glassmorphism

### When to Use
- **Overlay elements:** modals, popovers, floating toolbars, command palettes
- **Card overlays:** content cards that sit over a visually rich background 
- **Navigation:** sidebar or header over a blurred content area

### When NOT to Use
- **Body content areas** — glass effects reduce readability over long text
- **Data tables** — contrast issues with alternating rows 
- **Forms** — input fields need clear boundaries, not glass
- **Over plain backgrounds** — glass needs something behind it to look good 

### Implementation

```css
.glass {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.15);
  border-radius: 12px;
}

/* Dark mode variant */
.glass-dark {
  background: rgba(0, 0, 0, 0.2); 
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px); 
  border: 1px solid rgba(255, 255, 255, 0.08);  
}
```

### Caveats
- **Performance:** `backdrop-filter` is GPU-intensive. Limit to 2-3 glass elements per viewport.
- **Fallback:** Provide solid background for browsers that don't support `backdrop-filter`. 
- **Contrast:** Text on glass MUST meet WCAG AA contrast (4.5:1). Add a semi-opaque backing if needed.
- **Mobile:** Test on low-end devices. Reduce or remove blur on mobile if framerate drops. 

---

## Shadows

### Elevation System

Use consistent shadow depths that match your spacing scale:

```css  
:root {
  /* Subtle — cards, inputs at rest */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);

  /* Default — cards, dropdowns */
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 
               0 2px 4px -2px rgba(0, 0, 0, 0.1); 

  /* Elevated — popovers, floating elements */
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1),
               0 4px 6px -4px rgba(0, 0, 0, 0.1);

  /* High — modals, command palettes */ 
  --shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1),
               0 8px 10px -6px rgba(0, 0, 0, 0.1);
}
```

### Shadow Rules 

1. **Consistent light source.** All shadows come from the same direction (typically top). Never mix shadow directions.
2. **Higher = larger, softer shadow.** Elements closer to the user cast larger, more diffuse shadows.
3. **Interactive elements elevate on hover.** Card: `shadow-sm` → `shadow-md` on hover. Button: `shadow-sm` → `shadow-md` on hover, `shadow-none` on press.
4. **Dark mode shadows.** Increase opacity (`0.3` instead of `0.1`) or use lighter shadow color, since dark backgrounds absorb shadows.
5. **Never use shadows on flat designs.** If the design is intentionally flat, use borders instead. 

### Shadow + Hover Pattern 

```css
.card {  
  box-shadow: var(--shadow-sm);
  transition: box-shadow 200ms ease-out, transform 200ms ease-out;  
}
.card:hover { 
  box-shadow: var(--shadow-md); 
  transform: translateY(-2px);
}
.card:active {
  box-shadow: var(--shadow-sm);
  transform: translateY(0);
}
```

---

## Gradients

### Linear Gradients

```css
/* Subtle brand gradient — buttons, headers */
.gradient-brand {
  background: linear-gradient(135deg, var(--primary), var(--primary-dark));
} 

/* Subtle surface gradient — cards, sections */ 
.gradient-surface {
  background: linear-gradient(180deg, var(--bg-primary), var(--bg-secondary));
}
```

### Gradient Rules

1. **Max 2 colors for UI gradients.** 3+ colors = visual noise in interface elements.
2. **Same hue family.** Gradient between blue-400 and blue-600, not blue and orange.
3. **Direction matters.** `135deg` for dynamism. `180deg` (top-to-bottom) for calm. `90deg` (left-to-right) for progress.
4. **Avoid gradient text** unless it's a hero heading with a solid fallback. Gradient text on body copy is unreadable. 
5. **Dark mode.** Reduce gradient intensity — subtle tonal shifts, not vivid color changes.

### Gradient Anti-Patterns 

| Anti-Pattern | Why | Alternative |
|-------------|-----|-------------|
| Mesh gradients as default background | AI cliché, performance heavy | Solid color + subtle noise texture | 
| Rainbow gradients on buttons | Distracting, accessibility issues | Single-hue gradient (primary to primary-dark) | 
| Gradient borders everywhere | Visual clutter | Solid subtle border, save gradient for focus/active states |
| Animated gradients | Performance killer, distracting | Static gradient, animate opacity or position instead |
| Gradient text on small sizes | Illegible below 24px | Solid color text, gradient only for display headings |

---

## Borders & Dividers

### Border Scale 

```css
:root {
  --border-subtle: 1px solid rgba(0, 0, 0, 0.06);     /* Separation hint */
  --border-default: 1px solid rgba(0, 0, 0, 0.12);     /* Card, input default */ 
  --border-strong: 1px solid rgba(0, 0, 0, 0.2);       /* Emphasis, active state */
  --border-focus: 2px solid var(--primary);              /* Focus ring */
}
``` 

### Rules
1. **Use borders OR shadows, rarely both.** Exception: inputs with border + focus ring shadow.
2. **`border-radius` consistency.** Pick 2-3 values and use them everywhere: `4px` (small: badges, chips), `8px` (medium: cards, inputs), `12-16px` (large: modals, containers).
3. **Dividers vs. spacing.** Before adding a `<hr>` or border-bottom, try increasing vertical spacing. Often whitespace alone creates sufficient separation.

---

## Noise & Texture 

### Subtle Noise Pattern

```css
/* Adds organic texture to flat backgrounds */ 
.textured-bg { 
  background-color: var(--bg-primary);
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)' opacity='0.03'/%3E%3C/svg%3E");
}
```

**Use for:** Landing page backgrounds, hero sections, card surfaces that need warmth.
**Don't use for:** Data-heavy areas, form backgrounds, anywhere readability matters most.

---

## Effect Performance Budget

| Effect | Max Per Viewport | Performance Impact | 
|--------|-----------------|-------------------|
| `backdrop-filter: blur()` | 2-3 elements | High — GPU compositing |
| `box-shadow` (multiple values) | 10-15 elements | Low-Medium |
| CSS gradients | Unlimited (rendered once) | Negligible | 
| `filter: drop-shadow()` | 5-8 elements | Medium |
| Noise/texture overlay | 1-2 sections | Low (SVG filter) |
| Animated gradients | 0-1 elements | High — continuous repaint |  

**Rule:** If total effect count exceeds budget, prioritize the highest-impact effects and remove the rest. A fast page with fewer effects beats a slow page with all of them. 
