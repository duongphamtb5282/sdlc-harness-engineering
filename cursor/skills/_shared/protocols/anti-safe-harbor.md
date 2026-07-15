<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Anti-Safe-Harbor — Intentional Design Over Defaults

**Core principle: Every visual decision must be intentional. Default to asking, not assuming. Safe, generic aesthetics are a failure mode, not a feature.**

---

## What Is Safe Harbor?

"Safe harbor" is when an AI agent defaults to the same generic aesthetic choices regardless of the project's domain, audience, or brand identity. It produces technically correct but visually interchangeable products.

Safe harbor choices feel professional but lack personality. They signal "an AI built this" — which is the opposite of what users want. 

--- 

## Banned Defaults

These are NOT banned as choices — they're banned as DEFAULTS. If the user or domain research specifically calls for them, use them. But never reach for them automatically. 

| Banned Default | Why It's Problematic | When It IS Appropriate |
|----------------|---------------------|----------------------|  
| **Bento grid layouts** as the default page structure | Overused in AI-generated sites to the point of being a visual cliché. Every AI landing page looks the same. | Dashboard layouts where grid density is genuinely needed. Data-heavy comparison pages. |  
| **Mesh gradients** as the default background | Became the "AI-generated site" signature in 2024-2025. Signals lazy design. | Creative/artistic portfolios. Music/entertainment where visual intensity fits. |
| **Purple (#7C3AED or similar) as default accent** | Most overused AI-generated color choice. Creates instant "template" feeling. | Explicitly requested. Gaming, creative tools, or brands where purple IS the brand. |
| **Inter/Geist as the only font consideration** | Good fonts, but defaulting to them shows no design thinking. | When minimalism is explicitly the goal AND the domain research supports it. |
| **Generic hero with gradient text** | "Welcome to [Product]" with gradient heading is the AI landing page starter pack. | Never as default. If hero is needed, research the domain first. |
| **Card-based everything** | Not every content piece needs to be in a card. Cards add visual noise when used excessively. | Discrete, comparable items (products, plans, team members). Dashboard widgets. |
| **Blue CTA buttons with no domain reasoning** | Blue is safe but lazy. CTA color should match brand energy and conversion psychology. | When brand colors are blue, or domain research indicates trust-first UX (finance, healthcare). |

---

## The Rule: ASK Before Assuming Aesthetic

Before making ANY visual design decision, follow this hierarchy:

### 1. Check for Explicit Direction
- Does the BRD or user request specify a visual style?
- Is there a brand guide, color palette, or design system already?
- Did the Socratic Gate capture aesthetic preferences?  

### 2. Check Domain Intelligence
- Run `python3 search.py "[domain] [product-type]" --design-system` to get domain-appropriate recommendations
- Read `ux-psychology.md` for cognitive load and emotional design principles 
- Research competitors in the space — what visual language does this domain use? 

### 3. Ask if Still Unclear
If no explicit direction AND domain research yields multiple valid approaches:

```python 
AskUserQuestion(questions=[{ 
  "question": "For the visual design, I found these domain-appropriate styles:\n\n"
    "| Style | Mood | Best For |\n|---|---|---|\n"
    "| [A] | [mood] | [use case] |\n"  
    "| [B] | [mood] | [use case] |\n\n"
    "Which direction resonates?",
  "header": "Design Direction",
  "options": [
    {"label": "[Style A] (Recommended)", "description": "[why recommended for this domain]"},
    {"label": "[Style B]", "description": "[trade-off]"},
    {"label": "Surprise me — pick what fits best", "description": "Auto-select based on domain research"},
    {"label": "Chat about this", "description": "Free-form input"}
  ], 
  "multiSelect": false 
}])
```

### 4. Default with Intent (Autonomous Mode Only)
In Autonomous engagement mode, skip asking but DOCUMENT the reasoning:

```markdown
## Design Decisions (Auto-derived)  
- **Style:** [chosen] — because [domain research finding]
- **Palette:** [chosen] — because [product type mapping]
- **Typography:** [chosen] — because [mood/audience match]
- **Layout:** [chosen] — because [content type analysis]

None of these are "safe defaults." Each was selected from domain research. 
```

---

## What Intentional Design Looks Like

| Aspect | Safe Harbor (BAD) | Intentional (GOOD) |
|--------|-------------------|-------------------|  
| **Color** | `#7C3AED` purple because it "looks modern" | Domain-researched palette: fintech → trust blues, health → calming greens, creative → bold contrast |  
| **Typography** | Inter everywhere | Pairing researched for mood: editorial → serif + sans, SaaS → geometric sans, luxury → high-contrast serif |
| **Layout** | Bento grid for all pages | Content-driven: long-form → editorial single-column, dashboard → dense grid, marketing → narrative scroll |  
| **Animation** | Generic fade-in on scroll | Purpose-driven: progress indication, state transitions, attention guidance. Respects `prefers-reduced-motion`. |
| **Components** | Cards for everything | Contextual: tables for comparison data, cards for discrete items, inline for continuous content | 

---

## Enforcement 

### During Phase 2 (Design System) 
- Design tokens MUST come from domain research, not hardcoded defaults
- If using the search.py design system, the `--design-system` output justifies each choice
- If NOT using search.py, document WHY each design token was chosen

### During Phase 5 (Design & Polish)
- Before applying any visual style, check this protocol
- Every color, font, and layout choice must trace to: user request, brand guide, domain research, or explicit user selection
- If you cannot trace a choice to any of these, you're safe-harboring. Stop and research.

### In Code Review (SE Review Mode)
- Flag any design that uses ALL of: purple accent + Inter font + bento grid + mesh gradient
- Flag CTA colors that don't match the brand palette
- Flag font choices with no documented reasoning

---

## How Agents Load This Protocol

This protocol is auto-injected alongside other protocols. It primarily affects:
- **Software Engineer [frontend]** — during Phase 2 (Design System) and Phase 5 (Design & Polish) 
- **Software Engineer [review]** — during visual/UX review  
- **Solution Architect** — when recommending UI frameworks or design approaches

**Priority order:**
1. Iron Laws — highest
2. User's explicit design direction — always wins
3. Anti-Safe-Harbor (this file) — research before defaulting
4. Design asset recommendations — informed suggestions
5. Agent aesthetic judgment — lowest
