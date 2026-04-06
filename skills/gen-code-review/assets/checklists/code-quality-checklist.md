# Code Quality Checklist

Use this checklist when reviewing code for quality, security, and performance.

## Formatting and Style

- [ ] Follows the project's established coding style
- [ ] Consistent indentation and spacing
- [ ] Consistent naming conventions throughout
- [ ] File organization follows project conventions

## Testing

- [ ] Critical paths have test coverage
- [ ] Tests check behavior, not implementation details
- [ ] Tests are readable and serve as documentation
- [ ] Edge cases are tested (null, empty, boundary values)
- [ ] No flaky or timing-dependent tests
- [ ] Test names describe the scenario and expected outcome

## Security Basics

- [ ] No hardcoded secrets, API keys, or passwords
- [ ] No SQL/query concatenation (use parameterized queries)
- [ ] No unvalidated external input used directly
- [ ] No sensitive data in logs or error messages
- [ ] Authentication and authorization checks are present where needed
- [ ] Dependencies are up to date (no known vulnerabilities)

## Performance Red Flags

- [ ] No N+1 query patterns
- [ ] No unbounded loops or recursive calls without limits
- [ ] Pagination is used for large data sets
- [ ] No unnecessary re-renders (frontend)
- [ ] No loading excessive data when only a subset is needed
- [ ] No blocking operations on hot paths
- [ ] Database queries use appropriate indexes

## Logging and Observability

- [ ] Sufficient logging to debug production issues
- [ ] Not excessive logging that drowns signal in noise
- [ ] Log levels are appropriate (error, warn, info, debug)
- [ ] Structured logging format used where applicable
- [ ] Sensitive data is not logged

## API and Interface Design

- [ ] APIs are consistent with existing patterns
- [ ] Breaking changes are documented
- [ ] Input validation is present at system boundaries
- [ ] Error responses are consistent and informative
