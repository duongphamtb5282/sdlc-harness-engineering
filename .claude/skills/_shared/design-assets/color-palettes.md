<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Design Asset: Color Palettes

Curated color palettes by application type. Each palette provides CSS custom properties, hex values, and WCAG contrast compliance notes.

## WCAG Contrast Requirements

| Level | Normal Text (< 18px) | Large Text (>= 18px / 14px bold) |  
|-------|----------------------|----------------------------------|
| AA    | 4.5:1                | 3:1                              | 
| AAA   | 7:1                  | 4.5:1                            |

---

## 1. SaaS / Dashboard

```css
:root { 
  /* Primary */ 
  --color-primary-50:  #eff6ff; 
  --color-primary-100: #dbeafe;
  --color-primary-200: #bfdbfe;
  --color-primary-300: #93c5fd;
  --color-primary-400: #60a5fa;
  --color-primary-500: #3b82f6;  /* Main primary */
  --color-primary-600: #2563eb;
  --color-primary-700: #1d4ed8;
  --color-primary-800: #1e40af;
  --color-primary-900: #1e3a8a;
  --color-primary-950: #172554;

  /* Gray (Slate) */ 
  --color-gray-50:  #f8fafc;
  --color-gray-100: #f1f5f9;
  --color-gray-200: #e2e8f0;
  --color-gray-300: #cbd5e1; 
  --color-gray-400: #94a3b8;  
  --color-gray-500: #64748b;
  --color-gray-600: #475569;  
  --color-gray-700: #334155;  
  --color-gray-800: #1e293b;
  --color-gray-900: #0f172a;
  --color-gray-950: #020617; 

  /* Semantic surfaces */
  --color-background:      #ffffff;
  --color-surface:         #f8fafc;
  --color-surface-raised:  #ffffff;
  --color-border:          #e2e8f0;
  --color-border-strong:   #cbd5e1;

  /* Text */
  --color-text-primary:    #0f172a;  /* gray-900 on white: 15.4:1 AAA */  
  --color-text-secondary:  #475569;  /* gray-600 on white: 7.0:1 AAA */  
  --color-text-disabled:   #94a3b8;  /* gray-400 on white: 3.5:1 AA-large only */
  --color-text-on-primary: #ffffff;  /* white on primary-600: 7.2:1 AAA */

  /* Status */
  --color-success-50:  #f0fdf4;  --color-success-500: #22c55e;  --color-success-700: #15803d;
  --color-warning-50:  #fffbeb;  --color-warning-500: #f59e0b;  --color-warning-700: #b45309;
  --color-error-50:    #fef2f2;  --color-error-500:   #ef4444;  --color-error-700:   #b91c1c; 
  --color-info-50:     #eff6ff;  --color-info-500:    #3b82f6;  --color-info-700:    #1d4ed8;
}
```

**Contrast pairs (light mode):**

| Foreground       | Background | Ratio | Level | 
|------------------|-----------|-------|-------|
| gray-900 #0f172a | white     | 15.4  | AAA   |
| gray-600 #475569 | white     | 7.0   | AAA   |
| primary-600 #2563eb | white  | 5.2   | AA    |
| error-700 #b91c1c | white    | 6.6   | AA    | 
| success-700 #15803d | white  | 5.1   | AA    | 
| white            | primary-600 | 5.2 | AA    |

--- 

## 2. E-commerce

```css 
:root {
  --color-primary-500: #ea580c;  /* Warm orange */ 
  --color-primary-600: #c2410c; 
  --color-primary-700: #9a3412;
  --color-secondary-500: #0d9488; /* Teal accent */
  --color-accent-500: #e11d48;   /* Rose CTA — high contrast */
  --color-accent-600: #be123c;

  --color-background: #ffffff;
  --color-surface:    #faf5f2;   /* Warm off-white */
  --color-text-primary:   #1c1917;  /* stone-900, 16.8:1 on white AAA */
  --color-text-secondary: #57534e;  /* stone-600, 6.0:1 on white AA */
  --color-border:     #e7e5e4;

  /* CTA button: white on accent-600 #be123c = 5.6:1 AA */
  --color-cta-bg:   #be123c;
  --color-cta-text: #ffffff;

  /* Sale/promo */
  --color-sale:     #dc2626;
  --color-badge-new: #16a34a;  
}  
```

---

## 3. Healthcare

```css
:root {
  --color-primary-500: #0891b2;  /* Cyan-600 — trustworthy, clinical */
  --color-primary-600: #0e7490;
  --color-primary-700: #155e75;
  --color-secondary-500: #059669; /* Emerald — health, vitality */ 
  --color-secondary-600: #047857;

  --color-background: #ffffff;  
  --color-surface:    #f0fdfa;   /* Teal-50, clean feel */
  --color-text-primary:   #022c22;  /* 17.1:1 on white AAA */
  --color-text-secondary: #374151;  /* gray-700, 9.6:1 AAA */ 
  --color-border: #d1d5db; 

  /* High-contrast status for clinical data */
  --color-critical: #991b1b;  /* red-800, 9.4:1 on white AAA */
  --color-warning:  #92400e;  /* amber-800, 7.3:1 on white AAA */
  --color-normal:   #166534;  /* green-800, 7.8:1 on white AAA */
}
``` 

**Note:** Healthcare UIs must meet WCAG AA minimum. Prefer AAA for all body text. Never rely on color alone to convey status — always pair with icons or text labels.

---

## 4. Finance

```css 
:root {
  --color-primary-500: #1e3a5f;  /* Navy */
  --color-primary-600: #172d4d;
  --color-primary-700: #0f1f36; 
  --color-secondary-500: #475569; /* Slate gray */
  --color-accent-500: #ca8a04;   /* Gold/amber accent */
  --color-accent-600: #a16207;

  --color-background: #ffffff;
  --color-surface:    #f8fafc;
  --color-text-primary:   #0f172a; 
  --color-text-secondary: #475569;
  --color-border: #e2e8f0;

  --color-positive: #15803d;  /* green-700 for gains: 5.1:1 AA */  
  --color-negative: #b91c1c;  /* red-700 for losses: 6.6:1 AA */ 
  --color-neutral:  #475569;
}
```

---

## 5. Creative / Portfolio

```css
:root {
  --color-primary-500: #7c3aed;  /* Violet */
  --color-primary-600: #6d28d9;  
  --color-secondary-500: #ec4899; /* Pink */
  --color-accent-500: #06b6d4;   /* Cyan pop */

  --color-background: #fafafa;
  --color-surface:    #ffffff; 
  --color-text-primary:   #18181b;  /* zinc-900 */
  --color-text-secondary: #52525b;  /* zinc-600 */
  --color-border: #e4e4e7; 
} 
```

---

## 6. Developer Tools (Dark-Mode-First)

```css
:root {
  --color-primary-500: #8b5cf6;  /* Violet */
  --color-primary-400: #a78bfa;
  --color-secondary-500: #06b6d4; /* Cyan */

  /* Dark surfaces */
  --color-background:     #09090b;  /* zinc-950 */
  --color-surface:        #18181b;  /* zinc-900 */
  --color-surface-raised: #27272a;  /* zinc-800 */
  --color-border:         #3f3f46;  /* zinc-700 */

  /* Text on dark */
  --color-text-primary:   #fafafa;  /* zinc-50 on zinc-950: 19.4:1 AAA */
  --color-text-secondary: #a1a1aa;  /* zinc-400 on zinc-950: 7.5:1 AAA */
  --color-text-disabled:  #71717a;  /* zinc-500 on zinc-950: 4.6:1 AA */

  /* Syntax highlighting (One Dark inspired) */  
  --color-syntax-keyword:   #c678dd;  /* purple */
  --color-syntax-string:    #98c379;  /* green */
  --color-syntax-number:    #d19a66;  /* orange */
  --color-syntax-function:  #61afef;  /* blue */
  --color-syntax-comment:   #5c6370;  /* gray */
  --color-syntax-variable:  #e06c75;  /* red */
  --color-syntax-type:      #e5c07b;  /* yellow */ 
  --color-syntax-constant:  #56b6c2;  /* cyan */

  /* Status on dark */
  --color-success-400: #4ade80;
  --color-warning-400: #fbbf24;
  --color-error-400:   #f87171; 
  --color-info-400:    #60a5fa; 
}
```

**Contrast pairs (dark mode):**

| Foreground       | Background    | Ratio | Level |
|------------------|--------------|-------|-------|
| zinc-50 #fafafa  | zinc-950     | 19.4  | AAA   |
| zinc-400 #a1a1aa | zinc-950     | 7.5   | AAA   |
| violet-400 #a78bfa | zinc-950   | 7.1   | AAA   |
| cyan-500 #06b6d4 | zinc-950     | 6.8   | AA    |

---

## Tailwind Config Integration

```js
// tailwind.config.js — extend with chosen palette  
module.exports = {
  theme: {
    extend: {
      colors: { 
        primary: {
          50:  'var(--color-primary-50)',
          100: 'var(--color-primary-100)', 
          200: 'var(--color-primary-200)',
          300: 'var(--color-primary-300)', 
          400: 'var(--color-primary-400)',
          500: 'var(--color-primary-500)',
          600: 'var(--color-primary-600)',
          700: 'var(--color-primary-700)', 
          800: 'var(--color-primary-800)',
          900: 'var(--color-primary-900)',
          950: 'var(--color-primary-950)',  
        },
        // Repeat for secondary, accent, gray...
      },
    }, 
  },
}; 
``` 

## Quick Selection Guide 

| App Type        | Primary    | Mood              | Dark Mode Priority | 
|-----------------|-----------|-------------------|--------------------|
| SaaS/Dashboard  | Blue      | Professional      | Medium             |
| E-commerce      | Orange    | Warm, inviting    | Low                |
| Healthcare      | Cyan/Teal | Trustworthy       | Low                |
| Finance         | Navy      | Conservative      | Medium             |
| Creative        | Violet    | Expressive        | Medium             |
| Dev Tools       | Violet    | Technical         | High               |
