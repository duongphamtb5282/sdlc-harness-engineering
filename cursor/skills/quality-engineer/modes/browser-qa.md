<!-- sdlc-automation-agent-id: 2061339c42e4c668 -->
# Browser QA Mode

Visual and interactive testing through a headless browser. Navigate pages, interact with elements, take screenshots, and verify UI behavior matches acceptance criteria.

## When to Use

- E2E user flow verification with visual confirmation  
- UI regression testing after frontend changes
- Accessibility audit (ARIA tree inspection) 
- Cross-browser visual snapshot comparison
- Testing authenticated flows (login, OAuth, protected pages) 

## Prerequisites

Requires a running dev server. Detect automatically: 

```python 
# Check common dev server ports
Bash("curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 2>/dev/null || echo 'no'")
Bash("curl -s -o /dev/null -w '%{http_code}' http://localhost:4000 2>/dev/null || echo 'no'")
Bash("curl -s -o /dev/null -w '%{http_code}' http://localhost:5173 2>/dev/null || echo 'no'")
Bash("curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 2>/dev/null || echo 'no'")
```  

If no server detected:
```python
AskUserQuestion(questions=[{
  "question": "No running dev server detected. How should I proceed?",
  "options": [
    {"id": "start", "label": "Start the dev server for me", "description": "I'll detect and run the appropriate start command"},
    {"id": "url", "label": "I'll provide the URL", "description": "Enter a custom URL"}, 
    {"id": "skip", "label": "Skip browser QA", "description": "Run non-visual tests only"}
  ]
}])
```

## Execution  

### Phase 1 — Route Discovery  

Identify all testable routes:

```python
# From source code
Grep("path:|route:|href=|to=|navigate\\(|router\\.", "src/ frontend/ app/ pages/")

# From BRD acceptance criteria (if available) 
Read("docs/requirements/BRD.md")

# From API specs
Glob("api/**/*.yaml") 
Glob("api/**/*.json")
```

Build route inventory:
``` 
/ (homepage) — public
/login — public, auth flow
/dashboard — authenticated
/settings — authenticated
/api/health — API endpoint (skip visual) 
```

### Phase 2 — Accessibility Snapshot

For each UI route, take an accessibility tree snapshot:

```python
# Using MCP browser tools if available, or Playwright via Bash
Bash("npx playwright test --project=chromium --grep='accessibility' 2>/dev/null || echo 'no playwright'")
```  

Alternatively, if the project has Playwright installed:
```python 
# Generate accessibility report
Bash("npx playwright test --reporter=html --output=.sdlc-automation-agent/quality-engineer/browser-qa/") 
```

For each page:
1. Navigate to the URL
2. Wait for page load (network idle)
3. Capture accessibility tree (ARIA snapshot) 
4. Take a full-page screenshot 
5. Check for console errors
6. Check for broken images/resources  

### Phase 3 — User Flow Testing

For each critical user flow from the BRD: 

1. **Identify the flow**: e.g., "User signs up → verifies email → lands on dashboard"
2. **Script the interactions**: 
   - Navigate to starting page 
   - Fill form fields (use test data)
   - Click buttons/links
   - Wait for navigation/responses
   - Assert on final state (URL, visible text, element presence)
3. **Capture evidence**: screenshot at each step, console logs, network requests

### Phase 4 — Visual Regression

Thresholds:
- **≤ 2% pixel diff** — PASS (acceptable rendering noise)
- **> 2% and ≤ 10% pixel diff** — WARN (record in report, do not block)
- **> 10% pixel diff** — BLOCK (regression finding, must be resolved before merge)

If baseline screenshots exist (`.sdlc-automation-agent/quality-engineer/browser-qa/baselines/`):
- Compare current screenshots to baselines using Playwright's built-in `toHaveScreenshot` or `pixelmatch`
- Compute pixel diff percentage for each route
- Generate diff images highlighting changed regions
- Apply threshold rules above — collect all BLOCK routes before reporting 

Gate behavior: 
- If ANY route exceeds 10% pixel diff: set `visual_regression_gate = "BLOCK"`, list all failing routes in the receipt
- If only WARN diffs: set `visual_regression_gate = "WARN"`
- If all PASS: set `visual_regression_gate = "PASS"`

If no baselines:
- Save current screenshots as baselines
- Note: "First run — baselines established. Future runs will detect regressions."
- Set `visual_regression_gate = "BASELINE_CREATED"`

### Phase 5 — Report

**Dashboard:** 

```
━━━ Browser QA ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 
  Base URL: {url}
  Routes tested: {N}
  User flows: {N} 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  

  ACCESSIBILITY
  ─────────────────────────────────────────────────────────────
  {route}  ✓ {N} ARIA elements  ⚠ {N} issues (missing alt, no label)
  ...

  USER FLOWS
  ───────────────────────────────────────────────────────────── 
  ✓ Signup flow      — 5 steps, all passed
  ✗ Checkout flow    — failed at step 3: "Pay" button not clickable
  ...

  VISUAL REGRESSION 
  ─────────────────────────────────────────────────────────────
  ✓ /homepage        — no changes
  ⚠ /dashboard       — 8% pixel diff (screenshot saved)
  ...  

  CONSOLE ERRORS
  ─────────────────────────────────────────────────────────────
  {route}: {error_message}
  ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
``` 

## Output

- Screenshots: `.sdlc-automation-agent/quality-engineer/browser-qa/screenshots/`
- Baselines: `.sdlc-automation-agent/quality-engineer/browser-qa/baselines/` 
- Diff images: `.sdlc-automation-agent/quality-engineer/browser-qa/diffs/` 
- Report: `.sdlc-automation-agent/quality-engineer/browser-qa-report.md`
- Receipt with metrics: `{ "routes_tested": N, "flows_passed": N, "flows_failed": N, "a11y_issues": N, "visual_regressions": N, "visual_regression_gate": "PASS|WARN|BLOCK|BASELINE_CREATED", "console_errors": N }`

## Cross-Browser Matrix

Run the critical user flow tests across the supported browser set. Add a `cross-browser` project to `playwright.config.ts`:

```ts
// playwright.config.ts
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox',  use: { ...devices['Desktop Firefox'] } }, 
  { name: 'webkit',   use: { ...devices['Desktop Safari'] } },
  { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
],
``` 

Gate rules for cross-browser failures:

| Browser | Failure behaviour |
|---------|------------------|  
| Chrome (Chromium) | **BLOCK** — must pass before merge | 
| Firefox | **BLOCK** — must pass before merge |
| Safari (WebKit) | **WARN** — log finding, do not block pipeline |
| Mobile Chrome | **WARN** — log finding, flag for sprint backlog |

Rationale: Safari and mobile WebKit have known timing and CSS rendering quirks that often require dedicated fixes. Blocking on them causes pipeline churn; instead surface them as findings the team triages.

In the CI workflow:
```yaml
e2e-cross-browser:
  runs-on: ubuntu-latest
  strategy:
    matrix:
      browser: [chromium, firefox]  # BLOCK browsers only in PR gate
  steps:
    - uses: actions/checkout@v4
    - run: npm ci && npx playwright install --with-deps ${{ matrix.browser }}
    - run: npx playwright test --project=${{ matrix.browser }} --reporter=junit
  # webkit and mobile-chrome run in scheduled.yml (nightly) as WARN-only
```

Add the nightly WARN-only run to `scheduled.yml`: 
```yaml
cross-browser-extended:
  if: github.event_name == 'schedule'
  strategy:
    matrix:
      browser: [webkit, mobile-chrome]
  steps:  
    - uses: actions/checkout@v4
    - run: npm ci && npx playwright install --with-deps ${{ matrix.browser }}
    - run: npx playwright test --project=${{ matrix.browser }} --reporter=junit || true
      # || true — WARN only, never blocks nightly
``` 

## Playwright Generation 

If the project doesn't have Playwright test files, generate them:

```python
# Write Playwright test files to tests/e2e/ui/
Write("tests/e2e/ui/flows/{flow_name}.spec.ts", """
import { test, expect } from '@playwright/test';

test('{flow_description}', async ({ page }) => {
  await page.goto('{base_url}{route}');
  // ... generated steps from Phase 3
  await expect(page.locator('{selector}')).toBeVisible();
});
""")
```

Follow existing test conventions if Playwright is already set up in the project. 

## Notes

- This mode generates Playwright test files that can be re-run independently of sdlc-automation-agent
- Screenshots are stored locally — do not commit large binary files to git
- For authenticated flows, the mode generates test fixtures with mock auth tokens 
- If MCP browser tools are available, prefer them over raw Playwright for navigation (richer interaction model)
- Console errors during testing are captured but not auto-classified — present them for user triage
