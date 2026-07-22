<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# UX Psychology — Cognitive Principles for Interface Design

> **REQUIRED READ** before any frontend implementation work. Load this file at the start of Software Engineer [frontend] mode.

---

## Core UX Laws

### Hick's Law — Decision Time Increases with Choices 

**Principle:** The time to make a decision increases logarithmically with the number of options.

**Application:**
- Navigation menus: max 7±2 top-level items. Group related items into dropdowns.
- Form fields: break long forms into steps (wizard pattern). Show 3-5 fields per step. 
- Action buttons: one primary CTA per view. Secondary actions visually recede.
- Settings pages: progressive disclosure — show essential settings first, "Advanced" expandable.
- Pricing pages: 3 tiers maximum. Highlight recommended tier. 

**Anti-pattern:** Presenting 15 filter options simultaneously. Use progressive disclosure or smart defaults.

---

### Fitts's Law — Target Size and Distance Affect Speed

**Principle:** Time to reach a target is proportional to distance and inversely proportional to size.

**Application:** 
- Primary CTAs: minimum 44×44px touch target (WCAG). Desktop buttons: min 32px height.
- Mobile navigation: bottom nav for frequent actions (thumb zone). Top for infrequent.
- Form submit buttons: full-width on mobile, right-aligned on desktop (near the last field).
- Destructive actions (delete, cancel): smaller and farther from primary actions.
- Modal close button: top-right corner (muscle memory) + click-outside-to-close.
- Infinite scroll: "Back to top" button appears after 2 viewport heights of scrolling. 

**Anti-pattern:** Tiny "X" buttons on mobile. Links in dense paragraph text as the only navigation.

---

### Miller's Law — Working Memory Limits

**Principle:** People can hold 7±2 items in working memory. 

**Application:** 
- Dashboard cards: max 5-7 metric cards before grouping into tabs/sections.
- Breadcrumbs: show max 4 levels. Collapse middle levels with "..." for deep hierarchies.
- Table columns: show 5-7 columns by default. Additional columns behind "Customize columns." 
- Onboarding: 3-5 step progress indicator. Never show a 12-step wizard upfront.
- Error messages: one error at a time, or max 3 grouped by field. 

**Anti-pattern:** Showing all 20 dashboard widgets simultaneously with no visual hierarchy.

---

### Von Restorff Effect — Isolation Makes Things Memorable

**Principle:** Items that stand out from their surroundings are more likely to be noticed and remembered. 

**Application:**
- CTAs: use the brand's accent color ONLY for primary actions. Everything else: neutral.
- Pricing tables: visually elevate the recommended plan (scale, color, badge).
- Notifications: badges, dots, or color changes for new/unread items.
- Empty states: distinctive illustrations that stand out from regular content patterns. 
- Error states: red/orange for errors — but ONLY for errors. Don't use red decoratively. 

**Anti-pattern:** Multiple elements competing for attention with bright colors, animations, and badges simultaneously.

---  

### Serial Position Effect — First and Last Items Are Remembered

**Principle:** People best remember the first (primacy) and last (recency) items in a sequence.

**Application:**
- Navigation: most important item first, second most important last.
- Feature lists: lead with the strongest feature, end with the differentiator.
- Onboarding: first step = immediate value (not account setup). Last step = "you're ready!" 
- Form fields: put the most critical field first. Put the submit button last.
- Toast notifications: newest at bottom (recency), oldest scroll up and auto-dismiss.

**Anti-pattern:** Burying the most important navigation item in position 4 of 7. 

--- 

### Jakob's Law — Users Expect Your Site to Work Like Others

**Principle:** Users spend most of their time on OTHER sites. They expect yours to work the same way.

**Application:**
- Logo: top-left, links to home. Always. 
- Search: top-right or top-center. Magnifying glass icon. 
- Shopping cart: top-right with badge count. 
- User avatar/menu: top-right, after search.
- "Back" behavior: respect browser history. Never hijack the back button.
- Forms: labels above fields (not floating labels for critical forms).
- Links: underlined or colored. Never rely solely on hover state.
- 404 pages: clear message + search + home link.

**Anti-pattern:** Innovative navigation that breaks user expectations. Hamburger menu on desktop.

---

### Aesthetic-Usability Effect — Beautiful Things Feel Easier

**Principle:** Users perceive aesthetically pleasing designs as more usable, even if they aren't.

**Application:**
- Invest in visual polish AFTER functionality works (Phase 5, not Phase 2).
- Consistent spacing and alignment create perceived quality even with simple components. 
- Typography hierarchy (size, weight, color) creates order that reduces cognitive load. 
- Micro-interactions (button press feedback, loading shimmer, success check) feel polished.
- White space is not wasted space — it reduces cognitive load and increases perceived quality.

**Anti-pattern:** Spending 80% of time on visual polish for a broken form flow. 

---

## Emotional Design Principles

### Trust Signals

| Context | Trust Signal | Implementation |
|---------|-------------|----------------|
| **E-commerce** | Security badges, SSL lock, "Secure checkout" | Near payment forms, not in footer |
| **SaaS** | Social proof (logos, testimonials), uptime badge | Above the fold on pricing page |
| **Healthcare** | HIPAA badge, provider credentials, privacy policy link | Prominent on data entry forms |
| **Finance** | Regulatory compliance badges, encryption notice | Near account/transaction areas |
| **General** | Real company info (address, team, about page) | Footer + about page, not hidden |

### Feedback Loops

Every user action needs acknowledgment:

| Action | Expected Feedback | Timing |
|--------|------------------|--------|  
| Button click | Visual press state (scale/color change) | < 100ms | 
| Form submit | Loading indicator → Success/Error message | Immediate indicator, result < 3s |
| Navigation | Page transition or loading state | < 300ms perceived | 
| Data save | "Saved" indicator or auto-save dot | < 1s or continuous |
| Destructive action | Confirmation dialog with undo option | Before action executes |
| Long operation | Progress bar with estimated time | Within 1s of start | 

### Progressive Disclosure

Show only what's needed at each level:

``` 
Level 1: Summary (dashboard card, list item)  
  → Click: Level 2: Details (expanded view, detail page)  
    → Click: Level 3: Configuration (settings, advanced options)
      → Click: Level 4: Raw data (JSON, logs, audit trail)
```

Never show Level 3-4 content at Level 1. Users who need it will find it.

---

## Cognitive Load Reduction

### Visual Hierarchy Rules

1. **One focal point per viewport.** If everything is bold, nothing is bold.
2. **Size encodes importance.** Larger = more important. No exceptions. 
3. **Color encodes meaning.** Red = error/danger. Green = success. Yellow = warning. Blue = info. Don't mix.  
4. **Proximity encodes relationship.** Related items are closer together. Unrelated items have space between them.
5. **Consistency encodes patterns.** Same style = same function. Different style = different function.

### Information Density Guidelines

| Content Type | Max Density | Technique |
|-------------|-------------|-----------|
| Marketing pages | Low (40-60% white space) | Large type, generous padding, single-column flow | 
| Dashboards | Medium (20-40% white space) | Cards, grids, collapsible sections |
| Data tables | High (10-20% white space) | Compact rows, sticky headers, horizontal scroll | 
| Documentation | Medium-low (50-60% white space) | Sidebar nav, max 80ch line width, generous line height |
| Mobile screens | Low-medium (30-50% white space) | Stack vertically, larger touch targets, accordion sections |

--- 

## Accessibility as UX

Accessibility is not a separate concern — it IS good UX. These patterns help everyone:  

### Color
- Minimum contrast ratio: 4.5:1 for normal text, 3:1 for large text (WCAG AA)
- Never use color as the ONLY indicator — add icons, patterns, or text labels 
- Test with color blindness simulators (protanopia, deuteranopia, tritanopia) 

### Motion
- Respect `prefers-reduced-motion`: disable animations, transitions, auto-playing media 
- Essential motion (loading spinners, progress bars) may remain — decorative motion must stop
- Never auto-play video with sound. Auto-play silent video only if it serves a purpose.

### Keyboard
- Every interactive element must be keyboard-accessible (Tab, Enter, Space, Escape, Arrow keys) 
- Visible focus indicators — never `outline: none` without a replacement
- Skip-to-content link as the first focusable element  
- Modal trap: focus stays inside modal until closed. Escape closes modal.  

### Screen Readers
- Semantic HTML: `<nav>`, `<main>`, `<aside>`, `<article>`, `<button>`, not `<div onclick>`
- `aria-label` for icon-only buttons
- `aria-live` regions for dynamic content updates (notifications, live data)
- Form fields: visible `<label>` elements, not just placeholder text
- Images: descriptive `alt` text for informational images, empty `alt=""` for decorative
