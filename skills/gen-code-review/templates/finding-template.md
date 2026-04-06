# Code Review Finding Template

Use this template for individual findings when detailed explanation is needed.

```markdown
## [SEVERITY]: [Short Title]

**File**: `path/to/file.ext:NN`
**Category**: [Readability / Simplicity / Maintainability / Code Quality]

### Problem

[What is wrong and why it matters. Be specific.]

### Current Code

```[language]
// The problematic code
```

### Suggested Fix

```[language]
// The improved code
```

### Why This Matters

[Impact on readability, maintainability, performance, or correctness. 1-2 sentences.]
```

## Severity Reference

| Severity | Meaning | Action |
|----------|---------|--------|
| **MUST FIX** | Bugs, security issues, data loss risks | Block merge |
| **SHOULD FIX** | Complexity, poor naming, missing error handling | Fix before merge |
| **CONSIDER** | Minor improvements, style preferences | Optional |
| **PRAISE** | Well-written code worth highlighting | Acknowledge |
