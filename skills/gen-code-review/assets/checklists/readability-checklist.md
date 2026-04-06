# Readability Checklist

Use this checklist when reviewing code for readability (highest priority review dimension).

## Naming Clarity

- [ ] Function names describe what the function does (verb + noun)
- [ ] Variable names reveal intent, not type
- [ ] No cryptic abbreviations (`mgr`, `ctx`, `val`, `tmp`) unless universally understood
- [ ] Boolean variables read as questions (`isValid`, `hasPermission`, `canRetry`)
- [ ] Constants are named descriptively, not just UPPER_CASE versions of values

### Naming Anti-Patterns

| Bad | Good | Why |
|-----|------|-----|
| `processData()` | `calculateMonthlyRevenue()` | Reveals what processing means |
| `handleStuff()` | `validateUserEmail()` | Specific action, specific target |
| `mgr` | `orderManager` | No ambiguity |
| `val` | `discountAmount` | Reveals business meaning |
| `data` | `userProfiles` | Tells you what data |
| `flag` | `isEligibleForDiscount` | Tells you what the flag means |

## Function Length and Complexity

- [ ] Functions are under 30 lines (flag any over 50)
- [ ] Each function does one thing (describable without "and")
- [ ] Nesting depth is 3 levels or fewer
- [ ] Early returns / guard clauses used instead of deep nesting
- [ ] No function has more than 4-5 parameters

## Comments

- [ ] Comments explain "why", not "what"
- [ ] No commented-out code (use git history instead)
- [ ] No redundant comments restating the code
- [ ] Complex business rules have explanatory comments
- [ ] TODO comments include context (who, when, ticket number)

## Code Structure

- [ ] Related code is grouped together
- [ ] Imports are organized (stdlib, external, internal)
- [ ] No unnecessary blank lines or inconsistent spacing
- [ ] Consistent formatting follows project style
