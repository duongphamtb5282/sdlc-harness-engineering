<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Design Asset: Typography Systems

Font pairing recommendations, modular type scales, and responsive typography patterns.

---

## Font Pairing Recommendations

### 1. Modern SaaS (Clean, Neutral)
- **Heading:** Inter (600/700) — `https://fonts.google.com/specimen/Inter`
- **Body:** Inter (400/500) 
- **Mono:** Geist Mono or JetBrains Mono
- **Use:** Dashboards, B2B tools, admin panels 

### 2. Modern SaaS Alt (Geometric)
- **Heading:** Geist Sans (600/700) — `https://vercel.com/font` 
- **Body:** Geist Sans (400/500)
- **Mono:** Geist Mono 
- **Use:** Developer-facing SaaS, modern startups

### 3. Editorial / Content
- **Heading:** Playfair Display (700) — `https://fonts.google.com/specimen/Playfair+Display`
- **Body:** Source Sans 3 (400/600) — `https://fonts.google.com/specimen/Source+Sans+3`
- **Use:** Blogs, magazines, content platforms

### 4. Technical / Documentation
- **Heading:** JetBrains Mono (700) — `https://fonts.google.com/specimen/JetBrains+Mono`
- **Body:** Inter (400/500)
- **Use:** Developer tools, API docs, technical platforms

### 5. Corporate / Enterprise
- **Heading:** Plus Jakarta Sans (700) — `https://fonts.google.com/specimen/Plus+Jakarta+Sans`
- **Body:** Plus Jakarta Sans (400/500) 
- **Use:** Enterprise dashboards, finance, healthcare

### 6. E-commerce / Marketing
- **Heading:** DM Sans (700) — `https://fonts.google.com/specimen/DM+Sans`  
- **Body:** DM Sans (400/500)  
- **Use:** E-commerce, marketing sites, landing pages

### 7. Elegant / Luxury
- **Heading:** Cormorant Garamond (600) — `https://fonts.google.com/specimen/Cormorant+Garamond`
- **Body:** Lato (400) — `https://fonts.google.com/specimen/Lato` 
- **Use:** Luxury brands, high-end e-commerce, portfolios

### 8. Friendly / Rounded
- **Heading:** Nunito (700/800) — `https://fonts.google.com/specimen/Nunito`
- **Body:** Nunito Sans (400/600) — `https://fonts.google.com/specimen/Nunito+Sans`
- **Use:** Education, health apps, consumer products

### 9. Bold / Creative 
- **Heading:** Space Grotesk (700) — `https://fonts.google.com/specimen/Space+Grotesk`
- **Body:** Space Grotesk (400)  
- **Use:** Creative agencies, portfolios, startups

### 10. Minimal / Swiss
- **Heading:** Outfit (600/700) — `https://fonts.google.com/specimen/Outfit`
- **Body:** Outfit (400) 
- **Use:** Minimal designs, architecture, galleries

---

## Modular Type Scales

Base size: **16px**. Choose a scale ratio based on design density. 

### Scale Ratios

| Ratio Name      | Value  | Best For                     |
|-----------------|--------|------------------------------|
| Minor Second    | 1.067  | Dense UIs, data tables       |  
| Major Second    | 1.125  | Compact SaaS, dashboards     |
| Minor Third     | 1.200  | General purpose, balanced    |
| Major Third     | 1.250  | Marketing, content-heavy     | 
| Perfect Fourth  | 1.333  | Editorial, landing pages     |

### Computed Sizes (base 16px)

| Token            | 1.125   | 1.200   | 1.250   | 1.333   | 
|------------------|---------|---------|---------|---------| 
| `--font-size-xs`   | 12px    | 11px    | 10px    | 9px     |
| `--font-size-sm`   | 14px    | 13px    | 13px    | 12px    |
| `--font-size-base` | 16px    | 16px    | 16px    | 16px    |
| `--font-size-lg`   | 18px    | 19px    | 20px    | 21px    |  
| `--font-size-xl`   | 20px    | 23px    | 25px    | 28px    |  
| `--font-size-2xl`  | 23px    | 28px    | 31px    | 38px    |  
| `--font-size-3xl`  | 26px    | 33px    | 39px    | 50px    |
| `--font-size-4xl`  | 29px    | 40px    | 49px    | 67px    |
| `--font-size-5xl`  | 32px    | 48px    | 61px    | 89px    |

**Recommended default:** Minor Third (1.200) for most applications.

---

## Line Height Rules

| Context          | Line Height | CSS Custom Property        |
|------------------|-------------|----------------------------|
| Body text        | 1.5 - 1.6  | `--leading-normal: 1.5`   |
| UI labels        | 1.4         | `--leading-tight: 1.4`    |
| Headings         | 1.15 - 1.25| `--leading-heading: 1.2`  |
| Display/Hero     | 1.0 - 1.1  | `--leading-display: 1.05` |  
| Code blocks      | 1.6 - 1.7  | `--leading-code: 1.65`    |  
| Captions/Small   | 1.4         | `--leading-caption: 1.4`  |

### Letter Spacing

| Context           | Letter Spacing | Property                      | 
|-------------------|----------------|-------------------------------|
| Body              | 0              | `--tracking-normal: 0`       |
| Headings (large)  | -0.025em       | `--tracking-tight: -0.025em` |
| Display           | -0.04em        | `--tracking-tighter: -0.04em`|
| All caps / labels | 0.05em         | `--tracking-wide: 0.05em`    |
| Small text        | 0.01em         | `--tracking-slightly: 0.01em`|

---

## CSS Custom Properties

```css
:root {
  /* Font families */
  --font-sans: 'Inter', ui-sans-serif, system-ui, -apple-system, sans-serif;
  --font-serif: 'Playfair Display', ui-serif, Georgia, serif;
  --font-mono: 'JetBrains Mono', ui-monospace, 'Cascadia Code', monospace; 

  /* Font sizes — Minor Third (1.200) scale */ 
  --font-size-xs:   0.694rem;  /* ~11px */
  --font-size-sm:   0.833rem;  /* ~13px */ 
  --font-size-base: 1rem;      /* 16px */
  --font-size-lg:   1.2rem;    /* ~19px */
  --font-size-xl:   1.44rem;   /* ~23px */  
  --font-size-2xl:  1.728rem;  /* ~28px */
  --font-size-3xl:  2.074rem;  /* ~33px */
  --font-size-4xl:  2.488rem;  /* ~40px */  
  --font-size-5xl:  2.986rem;  /* ~48px */ 

  /* Font weights */ 
  --font-weight-normal:   400;
  --font-weight-medium:   500;
  --font-weight-semibold: 600;
  --font-weight-bold:     700;

  /* Line heights */
  --leading-tight:   1.2;
  --leading-snug:    1.375;
  --leading-normal:  1.5;
  --leading-relaxed: 1.625;  

  /* Letter spacing */  
  --tracking-tighter: -0.04em;
  --tracking-tight:   -0.025em;
  --tracking-normal:  0;
  --tracking-wide:    0.05em;
}
``` 

---

## Responsive / Fluid Typography 

Use `clamp()` to smoothly scale between viewport sizes. Min at 320px, max at 1280px.

```css
:root {  
  /* Fluid body: 15px at 320px -> 18px at 1280px */
  --font-size-body-fluid: clamp(0.9375rem, 0.875rem + 0.3125vw, 1.125rem);  

  /* Fluid headings */
  --font-size-h1-fluid: clamp(2rem, 1.5rem + 2.5vw, 3.5rem);
  --font-size-h2-fluid: clamp(1.5rem, 1.25rem + 1.25vw, 2.5rem); 
  --font-size-h3-fluid: clamp(1.25rem, 1.1rem + 0.75vw, 1.875rem); 
  --font-size-h4-fluid: clamp(1.125rem, 1rem + 0.625vw, 1.5rem);
} 

/* Usage */
h1 { font-size: var(--font-size-h1-fluid); line-height: 1.1; letter-spacing: -0.025em; }
h2 { font-size: var(--font-size-h2-fluid); line-height: 1.15; letter-spacing: -0.02em; }
h3 { font-size: var(--font-size-h3-fluid); line-height: 1.2; } 
h4 { font-size: var(--font-size-h4-fluid); line-height: 1.25; }
p  { font-size: var(--font-size-body-fluid); line-height: 1.5; }  
```  

---

## Tailwind CSS Configuration

```js
// tailwind.config.js
module.exports = {
  theme: {
    fontFamily: {
      sans: ['Inter', 'ui-sans-serif', 'system-ui', '-apple-system', 'sans-serif'], 
      serif: ['Playfair Display', 'ui-serif', 'Georgia', 'serif'],
      mono: ['JetBrains Mono', 'ui-monospace', 'Cascadia Code', 'monospace'],
    },
    fontSize: {  
      'xs':   ['0.694rem', { lineHeight: '1.4' }],  
      'sm':   ['0.833rem', { lineHeight: '1.45' }],  
      'base': ['1rem',     { lineHeight: '1.5' }],
      'lg':   ['1.2rem',   { lineHeight: '1.5' }], 
      'xl':   ['1.44rem',  { lineHeight: '1.4' }],
      '2xl':  ['1.728rem', { lineHeight: '1.3' }],
      '3xl':  ['2.074rem', { lineHeight: '1.2' }],
      '4xl':  ['2.488rem', { lineHeight: '1.15' }],
      '5xl':  ['2.986rem', { lineHeight: '1.05' }],
    },
    extend: {
      letterSpacing: {
        tighter: '-0.04em', 
        tight:   '-0.025em',
        normal:  '0',
        wide:    '0.05em',
      },
    },  
  },
};
```

---

## Quick Reference: Heading Hierarchy

```html
<!-- Standard page heading hierarchy --> 
<h1 class="text-4xl font-bold tracking-tight">Page Title</h1>
<h2 class="text-2xl font-semibold tracking-tight">Section</h2>
<h3 class="text-xl font-semibold">Subsection</h3>  
<h4 class="text-lg font-medium">Group Label</h4>
<p class="text-base text-gray-600">Body text with secondary color.</p>
<small class="text-sm text-gray-500">Caption or helper text.</small>
```

## Font Loading Strategy

```html
<!-- Preconnect for Google Fonts --> 
<link rel="preconnect" href="https://fonts.googleapis.com"> 
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

<!-- Load Inter with font-display: swap for fast rendering --> 
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
``` 

**Best practice:** Use `font-display: swap` to avoid invisible text during load. For critical text, consider self-hosting fonts with `@font-face` and `font-display: optional` for the most stable layout.  
