<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Animation Guide — Motion Design for Web Interfaces

> **Optional read** during Phase 5 (Design & Polish). Load when adding micro-interactions and transitions.

---

## Timing Principles

| Duration | Use Case | Examples |
|----------|----------|---------| 
| **100-150ms** | Instant feedback | Button press, toggle switch, checkbox, hover state |
| **200-300ms** | State transitions | Tab switch, accordion expand, dropdown open, tooltip appear | 
| **300-500ms** | Layout changes | Page transition, modal open/close, sidebar collapse, card flip |
| **500-800ms** | Attention guidance | Notification entrance, onboarding spotlight, success celebration |
| **1000ms+** | Rarely appropriate | Loading skeletons, complex data visualization transitions |

**Rule:** If it feels slow, it IS slow. Users perceive delays > 300ms as lag. Keep UI transitions under 300ms.

---

## Easing Functions

| Easing | CSS Value | When to Use |
|--------|-----------|-------------|
| **ease-out** | `cubic-bezier(0.0, 0.0, 0.2, 1)` | Elements entering the screen (slide in, fade in, scale up). Fast start, gentle landing. |
| **ease-in** | `cubic-bezier(0.4, 0.0, 1, 1)` | Elements leaving the screen (slide out, fade out). Slow start, fast exit. |
| **ease-in-out** | `cubic-bezier(0.4, 0.0, 0.2, 1)` | Elements staying on screen but changing state (resize, reposition, color change). |
| **linear** | `linear` | Continuous animations only: progress bars, loading spinners, infinite rotation. |
| **spring** | `cubic-bezier(0.34, 1.56, 0.64, 1)` | Playful UI: bouncy buttons, elastic modals, game-like interfaces. NOT for business/enterprise. |

**Rule:** Never use `linear` for UI transitions. Linear motion feels robotic. 

---

## Animation Patterns

### Entrance Animations

```css
/* Fade in (most versatile) */ 
@keyframes fadeIn { 
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Slide up (for cards, list items, notifications) */ 
@keyframes slideUp {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); } 
}

/* Scale in (for modals, popovers) */
@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.95); }  
  to { opacity: 1; transform: scale(1); }
}
```

**Keep transforms small.** `translateY(8px)` not `translateY(100px)`. `scale(0.95)` not `scale(0)`. Subtle > dramatic.

### Stagger Pattern (List Items)

When multiple items enter, stagger their appearance:

```css
.list-item {
  animation: slideUp 200ms ease-out both;
}
.list-item:nth-child(1) { animation-delay: 0ms; }
.list-item:nth-child(2) { animation-delay: 50ms; }
.list-item:nth-child(3) { animation-delay: 100ms; }  
/* Max 5 items staggered, then instant for remaining */
``` 

**Rule:** Max stagger delay = 250ms total. Beyond that, the page feels slow.

### Loading States

| State | Pattern | Duration | 
|-------|---------|----------| 
| **Skeleton** | Shimmer animation on placeholder shapes | Until content loads |
| **Spinner** | Rotating circle/dots | For indeterminate waits < 5s |
| **Progress bar** | Linear fill with percentage | For determinate operations |
| **Pulse** | Gentle opacity pulse on a placeholder | For content that will appear soon |  

```css  
/* Skeleton shimmer */  
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s ease-in-out infinite;
}
```

---

## Performance Constraints  

### GPU-Accelerated Properties (USE THESE)  
- `transform` (translate, scale, rotate)
- `opacity`
- `filter` (blur, brightness) 

### Layout-Triggering Properties (AVOID ANIMATING)
- `width`, `height` — use `transform: scale()` instead
- `top`, `left`, `right`, `bottom` — use `transform: translate()` instead
- `margin`, `padding` — causes reflow, use transform or gap
- `border-width` — use `box-shadow` or `outline` instead
- `font-size` — never animate this

### Rules
1. **Animate only `transform` and `opacity`** for smooth 60fps. Everything else causes layout recalculation.
2. **Use `will-change` sparingly.** Only on elements that WILL animate. Remove after animation completes.
3. **Never animate on scroll without `requestAnimationFrame`** or Intersection Observer.
4. **Test on low-end devices.** If an animation drops below 30fps on a 3-year-old phone, remove it.

---

## Reduced Motion

**MANDATORY:** Respect the user's `prefers-reduced-motion` preference. 

```css 
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after { 
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;  
    scroll-behavior: auto !important;
  }
}  
``` 

**What to keep in reduced motion:** 
- Loading spinners (essential feedback) — but simplify to opacity pulse
- Progress bars (essential feedback) — but remove animation, just update width
- Focus indicators (accessibility requirement)

**What to remove in reduced motion:**
- All decorative animations (parallax, floating elements, background motion)
- Entrance animations (items appear instantly)
- Page transitions (instant swap)
- Auto-scrolling carousels (stop completely, show manual controls)

---  

## Common Animation Mistakes  

| Mistake | Fix |
|---------|-----|
| Animating layout properties (width, height, margin) | Use `transform: scale()` and `transform: translate()` |
| Animation on every scroll event | Use Intersection Observer with `threshold` |
| No `prefers-reduced-motion` support | Add the media query above as a global reset |
| Entrance animation on page load blocks content | Use `animation-fill-mode: both` and keep durations < 300ms | 
| Spinner shown for < 200ms operations | Add 200ms delay before showing spinner — instant results shouldn't flash a loader |
| Exit animation that delays navigation | Navigation should be instant. Animate the NEW page in, don't animate the old page out. | 
| `will-change` on every element | Only on elements about to animate. Too many `will-change` = more memory, worse performance. |
| Parallax scrolling on mobile | Disable parallax on touch devices. It fights with native scroll momentum. |
