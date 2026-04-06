# Simplicity Checklist

Use this checklist when reviewing code for unnecessary complexity.

**Core Rule: If a junior developer cannot understand it in 5 minutes, it is too complex.**

## Anti-Pattern Detection

- [ ] No premature abstractions (interfaces with only 1 implementation)
- [ ] No over-generalization (generic utils for single use cases)
- [ ] No callback/promise hell (deeply nested async chains)
- [ ] No clever one-liners (dense chained operations sacrificing readability)
- [ ] No pattern worship (Factory-of-Factory, Strategy for 2 cases)
- [ ] No unnecessary indirection (service calls service calls service)
- [ ] No speculative generality (config-driven for 1 config value)
- [ ] No magic numbers/strings (unexplained literals in code)

## Anti-Pattern Quick Reference

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

## Complexity Indicators

- [ ] No function requires scrolling to read entirely
- [ ] No class requires reading multiple files to understand
- [ ] No data transformation requires tracing through 3+ layers
- [ ] Architecture layers match actual complexity (no 4-layer CRUD)
- [ ] Abstractions exist because of real need, not anticipated need

## Decision Test

For each abstraction or pattern found, ask:

1. Does this solve a problem that exists **today** (not hypothetically)?
2. Are there **3+ variants** that justify the abstraction?
3. Would removing this make the code **harder** to understand?

If the answer to all three is "no", flag it as unnecessary complexity.
