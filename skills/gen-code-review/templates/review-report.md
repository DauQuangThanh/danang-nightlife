# Code Review Report Template

Use this template for all code review outputs. Copy and fill in each section.

```markdown
# Code Review: [Module/PR Name]

**Reviewer**: [Agent/Name]
**Date**: [YYYY-MM-DD]
**Scope**: [Files/directories/PR reviewed]

## Summary

| Metric | Value |
|--------|-------|
| Files reviewed | [count] |
| Overall verdict | [APPROVE / REQUEST CHANGES / NEEDS DISCUSSION] |
| Simplicity score | [1-5] (5 = simple and clear, 1 = over-engineered) |
| Maintainability score | [1-5] (5 = easy to modify, 1 = fragile) |
| Total findings | [count] |

## Key Findings

### MUST FIX (Blocks merge)

| # | File:Line | Issue | Impact | Suggested Fix |
|---|-----------|-------|--------|---------------|
| 1 | `path/file.ext:NN` | Description | [Bug/Security/Data loss] | Code or explanation |

### SHOULD FIX (Strongly recommended before merge)

| # | File:Line | Issue | Impact | Suggested Fix |
|---|-----------|-------|--------|---------------|
| 1 | `path/file.ext:NN` | Description | [Complexity/Naming/Error handling] | Code or explanation |

### CONSIDER (Optional improvements)

| # | File:Line | Suggestion |
|---|-----------|------------|
| 1 | `path/file.ext:NN` | Description of improvement |

### PRAISE (Good patterns to reinforce)

| # | File:Line | What was done well |
|---|-----------|-------------------|
| 1 | `path/file.ext:NN` | Description of good pattern |

## Simplicity Assessment

[2-3 sentences on overall simplicity. Biggest win and biggest concern.]

## Maintainability Assessment

[2-3 sentences on maintainability. Key strengths and risks.]

## Recommendations

[Ordered list of concrete next steps, most impactful first.]

1. [Most critical action]
2. [Second priority]
3. [Third priority]

## Files Reviewed

| File | Status | Findings |
|------|--------|----------|
| `path/file1.ext` | [Reviewed/Skipped] | [count] findings |
```

## Usage Notes

- **Simplicity score guide**: 5 = junior dev understands in 5 min; 4 = clear with minor issues; 3 = some unnecessary complexity; 2 = significantly over-engineered; 1 = impenetrable
- **Maintainability score guide**: 5 = easy to modify confidently; 4 = mostly safe to change; 3 = some fragile areas; 2 = high risk of breakage; 1 = afraid to touch
- **Always include at least one PRAISE item** to reinforce good patterns
- **Every MUST FIX and SHOULD FIX must include a suggested fix** with concrete code
