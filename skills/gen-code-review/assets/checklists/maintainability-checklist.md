# Maintainability Checklist

Use this checklist when reviewing code for long-term maintainability.

## Single Responsibility

- [ ] Each function/class/component does one thing
- [ ] Can describe each unit without using "and"
- [ ] Changes to one feature don't require touching unrelated files
- [ ] Business logic is separated from infrastructure concerns

## Dependencies

- [ ] Dependencies are explicit (injected or imported), not hidden
- [ ] No global mutable state
- [ ] No tight coupling between unrelated modules
- [ ] Circular dependencies are absent
- [ ] External dependencies are wrapped at boundaries (easy to swap)

## Error Handling

- [ ] Error handling is consistent across the codebase
- [ ] No swallowed exceptions (empty catch blocks)
- [ ] No try-catch around infallible code
- [ ] Error messages are descriptive and actionable
- [ ] Errors propagate appropriately (not over-caught, not under-caught)
- [ ] Edge cases (null, empty, boundary values) are handled

## Dead Code

- [ ] No commented-out code blocks
- [ ] No unused imports
- [ ] No unreachable branches or conditions
- [ ] No unused variables, functions, or classes
- [ ] No deprecated code without migration path

## Duplication

- [ ] No 3+ identical code blocks (extract if 3+, tolerate if 2)
- [ ] Shared logic is extracted to appropriate level (not too early)
- [ ] Copy-paste code has been reviewed for subtle differences

## Testability

- [ ] Code is structured to be testable without excessive mocking
- [ ] Side effects are isolated and injectable
- [ ] Pure functions are used where possible
- [ ] Test boundaries align with module boundaries
