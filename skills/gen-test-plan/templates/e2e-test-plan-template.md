# E2E Test Plan: [FEATURE_NAME]

> **Generated**: [DATE]
> **Source**: spec.md, design.md, test-plan.md
> **Feature Branch**: [BRANCH_NAME]
> **E2E Framework**: Playwright

## 1. E2E Testing Strategy

### Browser Matrix

| Browser | Viewport | Priority |
|---|---|---|
| Chromium (Desktop) | 1280×720 | P1 |
| Firefox (Desktop) | 1280×720 | P2 |
| WebKit/Safari (Desktop) | 1280×720 | P2 |
| Chromium (Mobile) | 375×667 (iPhone SE) | P1 |
| Chromium (Tablet) | 768×1024 (iPad) | P3 |

### Playwright Configuration

```typescript
// playwright.config.ts key settings
{
  testDir: './tests/e2e',
  timeout: 30_000,
  retries: 2,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    trace: 'retain-on-failure',
  }
}
```

### Test Data Management

- **Strategy**: [Factory / Seed / API setup]
- **Isolation**: Each test creates its own data via API or UI
- **Cleanup**: [After each test / After suite / Automatic]

### Locator Strategy

Use stable selectors in this priority order:

1. `getByRole()` — accessibility roles (button, link, heading)
2. `getByLabel()` — form labels
3. `getByText()` — visible text
4. `getByTestId()` — data-testid attributes (last resort)

---

## 2. User Flow Test Scenarios

### Flow 1: [FLOW_NAME]

**Priority**: P1
**User Story**: [US reference]
**Preconditions**: [Required state before test]

#### Steps:

1. Navigate to [URL/page]
2. [Action]: [Specific interaction]
3. [Assertion]: Verify [expected outcome]
4. [Action]: [Next interaction]
5. [Assertion]: Verify [expected outcome]

#### Expected Results:

- [Final UI state]
- [Data changes]
- [Navigation result]

#### Playwright Test Script:

```typescript
import { test, expect } from '@playwright/test';

test.describe('[FLOW_NAME]', () => {
  test.beforeEach(async ({ page }) => {
    // Preconditions: setup test state
  });

  test('happy path', async ({ page }) => {
    // Step 1: Navigate
    await page.goto('/path');

    // Step 2: Interact
    await page.getByLabel('[LABEL]').fill('[VALUE]');
    await page.getByRole('button', { name: '[BUTTON_TEXT]' }).click();

    // Step 3: Assert
    await expect(page.getByText('[EXPECTED_TEXT]')).toBeVisible();
  });

  test('error path: [ERROR_SCENARIO]', async ({ page }) => {
    await page.goto('/path');

    // Trigger error condition
    await page.getByLabel('[LABEL]').fill('[INVALID_VALUE]');
    await page.getByRole('button', { name: '[BUTTON_TEXT]' }).click();

    // Assert error state
    await expect(page.getByRole('alert')).toContainText('[ERROR_MESSAGE]');
  });

  test('edge case: [EDGE_CASE]', async ({ page }) => {
    // Edge case test implementation
  });
});
```

#### Variants:

- [ ] Happy path
- [ ] Error path: [specific error scenario]
- [ ] Edge case: [specific edge case]

---

### Flow 2: [FLOW_NAME]

**Priority**: [P1/P2/P3]
**User Story**: [US reference]
**Preconditions**: [Required state]

[Repeat structure from Flow 1]

---

## 3. Cross-Browser and Responsive Tests

### Viewport-Specific Scenarios

| Scenario | Desktop | Mobile | Tablet | Notes |
|---|---|---|---|---|
| [SCENARIO] | ✅ | ✅ | ⬜ | [Notes on responsive behavior] |

### Mobile-Specific Interactions

- [ ] Touch navigation: [Scenario]
- [ ] Viewport scroll: [Scenario]
- [ ] Soft keyboard: [Form interaction scenario]

---

## 4. Visual Regression Tests

### Pages Requiring Visual Snapshots

| Page/Component | Viewports | Threshold | Notes |
|---|---|---|---|
| [PAGE] | Desktop, Mobile | 0.1% | [Baseline notes] |

### Playwright Visual Comparison:

```typescript
test('visual regression: [PAGE]', async ({ page }) => {
  await page.goto('/path');
  await expect(page).toHaveScreenshot('[snapshot-name].png', {
    maxDiffPixelRatio: 0.001,
  });
});
```

---

## 5. Playwright MCP Server Integration

### Running E2E Tests via MCP

The Playwright MCP server provides browser automation tools for interactive E2E testing:

- **`browser_navigate`** — navigate to URLs
- **`browser_click`** — click elements by text, selector, or coordinates
- **`browser_type`** — type text into input fields
- **`browser_snapshot`** — capture accessibility snapshot for assertions
- **`browser_screenshot`** — capture visual screenshot

### Interactive Test Execution Flow

```
1. browser_navigate → Load page under test
2. browser_snapshot → Verify initial state (accessibility tree)
3. browser_click / browser_type → Perform user interactions
4. browser_snapshot → Verify result state
5. browser_screenshot → Capture evidence (on failure)
```

### MCP Test Scenarios

For each critical flow, define the MCP interaction sequence:

#### [Flow Name] via MCP:

1. `browser_navigate` to [URL]
2. `browser_snapshot` → expect [element] in accessibility tree
3. `browser_type` "[value]" into [field description]
4. `browser_click` "[button text]"
5. `browser_snapshot` → expect [success indicator]

---

## 6. Test Execution Order

```
Phase 1: Smoke tests (P1 happy paths only)
    ↓
Phase 2: Full P1 flows (happy + error + edge)
    ↓
Phase 3: P2 flows
    ↓
Phase 4: Cross-browser verification
    ↓
Phase 5: Visual regression
    ↓
Phase 6: P3 flows and exploratory testing
```

---

## 7. Test Statistics

- **Total E2E Flows**: [COUNT]
- **Total Test Cases**: [COUNT] (happy: [N], error: [N], edge: [N])
- **P1 Flows**: [COUNT]
- **P2 Flows**: [COUNT]
- **P3 Flows**: [COUNT]
- **Browser Combinations**: [COUNT]
- **Visual Snapshots**: [COUNT]

---

*This E2E test plan provides Playwright-ready test scripts for all critical user flows with cross-browser and responsive coverage.*
