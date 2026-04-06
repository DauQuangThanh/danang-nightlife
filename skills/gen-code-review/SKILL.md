---
name: gen-code-review
description: "Reviews source code for simplicity, maintainability, and quality. Flags over-engineered patterns, unnecessary abstractions, and clever-but-unreadable code. Use when reviewing pull requests, auditing codebases, refactoring for clarity, or when user mentions code review, simplicity check, maintainability audit, or code quality."
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "1.2.0"
  last_updated: "2026-02-08"
  category: code-review
  tags: "code-review, simplicity, maintainability, quality, refactoring"
---

# General Code Review

## Overview

This skill reviews source code across any language, framework, or tier (backend, frontend, CLI, libraries) with a core philosophy: **code simplicity over code smart**. It identifies over-engineered solutions, unnecessary abstractions, and clever-but-unreadable patterns. The goal is code that any team member can read, understand, and modify confidently within minutes -- not code that impresses with its sophistication.

## When to Use

- Reviewing pull requests or merge requests
- Assessing code quality before merging to main branch
- Identifying over-engineered or unnecessarily complex code
- Refactoring code for better maintainability
- Auditing existing codebases for simplicity and readability
- When user mentions "code review", "simplicity check", "maintainability", or "code quality"

## Prerequisites

- Access to the source code files to review
- Understanding of the project's primary language and framework (detected automatically)

## Instructions

### Step 1: Scope the Review

Determine what to review:

1. **If reviewing a PR/diff**: Focus on changed files only. Read the diff first.
2. **If reviewing a module/service**: Identify entry points and work inward.
3. **If reviewing the full codebase**: Start with the most-changed files (use `git log --format= --name-only | sort | uniq -c | sort -rn | head -20`).

Collect context:

- What language and framework is used?
- What does this code do at a high level?
- Are there existing coding standards or conventions?

### Step 2: Apply the Simplicity-First Review

Review every file through these lenses, in order of priority:

#### 2.1 Readability (Highest Priority)

Check for:

- **Naming clarity**: Can you understand what a function does from its name alone? Variables should reveal intent, not type.
  - Bad: `processData()`, `handleStuff()`, `mgr`, `ctx`, `val`
  - Good: `calculateMonthlyRevenue()`, `validateUserEmail()`, `orderManager`, `requestContext`
- **Function length**: Functions over 30 lines likely do too much. Flag any over 50 lines.
- **Nesting depth**: More than 3 levels of nesting is a red flag. Suggest early returns or guard clauses.
- **Comments explaining "what"**: If code needs a comment to explain what it does, the code should be rewritten to be self-explanatory. Comments should only explain "why".

#### 2.2 Simplicity (Core Principle)

**Rule: If a junior developer cannot understand it in 5 minutes, it is too complex.**

Flag these anti-patterns:

| Anti-Pattern | What It Looks Like | Simple Alternative |
|---|---|---|
| Premature abstraction | Interface with 1 implementation | Use the concrete class directly |
| Over-generalization | Generic util for every edge case | Write specific code for the actual case |
| Callback/promise hell | Deeply nested async chains | Flatten with async/await or named functions |
| Clever one-liners | Dense chained operations | Break into readable named steps |
| Pattern worship | Factory-of-factory, strategy for 2 cases | Direct code; add pattern when 3+ variants exist |
| Unnecessary indirection | Service calls service calls service | Reduce layers; call the dependency directly |
| Speculative generality | Config-driven for 1 config value | Hardcode it; make configurable when needed |
| Magic numbers/strings | Unexplained literals in code | Named constants with clear meaning |

#### 2.3 Maintainability

Check for:

- **Single Responsibility**: Does each function/class/component do one thing? Can you describe it without "and"?
- **Dependency clarity**: Are dependencies explicit (injected or imported), not hidden?
- **Error handling**: Consistent and proportional? No swallowed exceptions. No try-catch around infallible code.
- **Dead code**: Remove commented-out code, unused imports, unreachable branches.
- **Duplication threshold**: 3+ identical blocks warrant extraction. 2 similar blocks do not.

#### 2.4 Code Quality

Check for:

- **Consistent formatting**: Follows the project's established style.
- **Meaningful tests**: Critical paths tested. Tests check behavior, not implementation.
- **Security basics**: No hardcoded secrets, no SQL/query concatenation, no unvalidated external input.
- **Performance red flags**: N+1 queries, unbounded loops, missing pagination, unnecessary re-renders, loading excessive data.
- **Logging/observability**: Enough to debug production. Not so much it drowns signal in noise.

### Step 3: Classify Findings

Categorize each finding by severity:

| Severity | Meaning | Action Required |
|---|---|---|
| **MUST FIX** | Bugs, security issues, data loss risks | Block merge until resolved |
| **SHOULD FIX** | Complexity, poor naming, missing error handling | Fix before merge (strongly recommended) |
| **CONSIDER** | Minor improvements, style preferences | Optional; discuss with author |
| **PRAISE** | Well-written simple code worth highlighting | Acknowledge to reinforce good patterns |

### Step 4: Generate Review Report

Produce a structured review:

```markdown
# Code Review: [Module/PR Name]

## Summary
- **Files reviewed**: [count]
- **Overall verdict**: [APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]
- **Simplicity score**: [1-5] (5 = simple and clear, 1 = over-engineered)
- **Maintainability score**: [1-5] (5 = easy to modify, 1 = fragile)

## Key Findings

### MUST FIX
- [file:line] Description. **Why**: [impact]. **Fix**: [suggestion].

### SHOULD FIX
- [file:line] Description. **Why**: [impact]. **Fix**: [suggestion].

### CONSIDER
- [file:line] Description of suggestion.

### PRAISE
- [file:line] Description of what was done well.

## Simplicity Assessment
[2-3 sentences on overall simplicity. Biggest win and biggest concern.]

## Recommendations
[Ordered list of concrete next steps, most impactful first.]
```

### Step 5: Provide Actionable Feedback

For every finding:

1. **Point to the exact location**: file path and line number.
2. **Explain the problem**: What is wrong and why it matters.
3. **Show the fix**: Provide concrete code, not just a description.
4. **Keep it kind**: Review the code, not the person. Use "this code" not "you".

## Examples

### Example 1: Over-Engineered Service Layer

**Input**: A simple CRUD operation wrapped in 4 layers of abstraction.

```python
# SHOULD FIX: Unnecessary abstraction layers for simple CRUD
# Current: Controller -> Service -> Repository -> DAL -> Database
# For "get user by ID" with no business logic, this adds complexity without value.

# Before (over-engineered):
class UserController:
    def get_user(self, id):
        return self.user_service.get_user(id)

class UserService:
    def get_user(self, id):
        return self.user_repository.get_user(id)

class UserRepository:
    def get_user(self, id):
        return self.user_dal.get_user(id)

class UserDAL:
    def get_user(self, id):
        return db.query(User).filter(User.id == id).first()

# After (simple, direct):
class UserController:
    def get_user(self, id):
        return db.query(User).filter(User.id == id).first()
        # Add a service layer ONLY when business logic actually exists
```

### Example 2: Clever vs. Clear Code

**Input**: A dense one-liner doing multiple transformations.

```javascript
// SHOULD FIX: Clever one-liner sacrifices readability
// Before:
const result = data.reduce((a, x) => ({...a, [x.k]: [...(a[x.k]||[]), x]}), {});

// After (clear, readable):
const groupedByKey = {};
for (const item of data) {
  if (!groupedByKey[item.key]) {
    groupedByKey[item.key] = [];
  }
  groupedByKey[item.key].push(item);
}
```

### Example 3: Praise for Simple Code

```java
// PRAISE: Clean guard clause pattern, easy to follow
public Order processOrder(OrderRequest request) {
    if (request == null) {
        throw new IllegalArgumentException("Order request cannot be null");
    }
    if (request.getItems().isEmpty()) {
        throw new ValidationException("Order must have at least one item");
    }
    if (!inventory.hasStock(request.getItems())) {
        throw new InsufficientStockException("Not enough inventory");
    }

    Order order = Order.from(request);
    order.calculateTotal();
    return orderRepository.save(order);
}
```

## Key Rules

1. **Simple > Smart**: Always prefer the straightforward solution over the clever one.
2. **No speculative abstractions**: Do not build for hypothetical futures.
3. **Three strikes then abstract**: Duplication is OK until 3+ instances, then extract.
4. **Flat > Nested**: Prefer early returns over nested if-else chains.
5. **Explicit > Implicit**: Make data flow visible. No hidden side effects or magic values.
6. **Delete > Comment out**: Remove dead code. Git preserves history.
7. **Review the code, not the person**: Constructive and specific feedback only.
8. **Every finding needs a fix**: Show the solution, not just the problem.
9. **Praise good code**: Reinforce simple, clean patterns when you see them.
10. **Proportional effort**: More time on business logic, less on boilerplate.

## Edge Cases

### Case 1: Legacy Codebase with Established Patterns

**Handling**: Do not flag existing patterns in unchanged code. Focus on new/modified code. Note legacy patterns as "CONSIDER" for future refactoring, not "MUST FIX".

### Case 2: Performance-Critical Code Requiring Complexity

**Handling**: Accept necessary complexity when backed by evidence (benchmarks, profiling). Require a comment explaining why the complex approach is needed and what the simpler alternative would be.

### Case 3: Framework-Mandated Patterns

**Handling**: Do not flag patterns required by the framework (e.g., Spring DI annotations, Django class-based views, React hooks rules, Angular decorators). Focus on the code within those patterns.

## Error Handling

### Error: Cannot Determine Language or Framework

**Action**: Ask the user to specify the primary language and framework. Fall back to language-agnostic review principles.

### Error: No Files to Review

**Action**: Ask the user to specify the files, directory, or PR. If reviewing a PR, use `git diff` to identify changed files.

### Error: Conflicting Coding Standards

**Action**: Follow the project's existing conventions over personal preference. Note inconsistencies as "CONSIDER" and suggest establishing standards.

### Warning: Review Scope Too Large

**Action**: If more than 100 files, ask the user to narrow scope. Provide partial review with clear indication of what was and was not covered.

## Templates

Ready-to-use templates for review outputs:

- **[Review Report Template](templates/review-report.md)** -- Structured report with summary, findings by severity, scores, and recommendations. Copy and fill for every review.
- **[Finding Template](templates/finding-template.md)** -- Detailed finding format with problem, current code, suggested fix, and impact. Use for complex findings that need full explanation.

## Checklists

Apply these checklists during the review (Step 2). Each covers one dimension:

- **[Readability Checklist](assets/checklists/readability-checklist.md)** -- Naming clarity, function length, nesting depth, comments, code structure
- **[Simplicity Checklist](assets/checklists/simplicity-checklist.md)** -- Anti-pattern detection, complexity indicators, abstraction decision tests
- **[Maintainability Checklist](assets/checklists/maintainability-checklist.md)** -- Single responsibility, dependencies, error handling, dead code, duplication
- **[Code Quality Checklist](assets/checklists/code-quality-checklist.md)** -- Formatting, testing, security basics, performance red flags, logging
- **[Review Completion Checklist](assets/checklists/review-completion-checklist.md)** -- Verify coverage, finding quality, report completeness, review principles

## Success Criteria

Review is complete when:

- [ ] All files in scope have been reviewed
- [ ] Every finding includes file path, line number, explanation, and suggested fix
- [ ] Findings are categorized by severity (MUST FIX / SHOULD FIX / CONSIDER / PRAISE)
- [ ] Simplicity score (1-5) and maintainability score (1-5) are provided
- [ ] Overall verdict is given (APPROVE / REQUEST CHANGES / NEEDS DISCUSSION)
- [ ] At least one PRAISE item is included
- [ ] Report follows the [Review Report Template](templates/review-report.md)
- [ ] All dimension checklists have been applied
- [ ] All suggestions follow "simple > smart" principle
