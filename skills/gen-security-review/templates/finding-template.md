# Security Finding Template

Use this template for each individual finding when documenting security issues outside of the full report.

---

## [ID] [Severity] [OWASP Category] Title

**Severity**: CRITICAL / HIGH / MEDIUM / LOW / INFO
**OWASP Category**: A01-A10
**CWE**: CWE-XXX
**Location**: `file/path.ext:line`

### Description

[Clear description of the vulnerability — what the flaw is and why it's a problem.]

### Impact

[What an attacker can achieve by exploiting this vulnerability.]

| Impact Area | Level |
|------------|-------|
| Confidentiality | High / Medium / Low / None |
| Integrity | High / Medium / Low / None |
| Availability | High / Medium / Low / None |

### Exploitation Scenario

> Required for CRITICAL and HIGH findings.

1. Attacker [action]
2. Application [behavior]
3. Result: [consequence]

### Proof of Concept

> Optional. Include for CRITICAL findings when safe to demonstrate.

```
[PoC request/payload]
```

### Remediation

**Before (vulnerable):**

```language
// Vulnerable code
```

**After (secure):**

```language
// Fixed code
```

**Additional hardening** (optional):

- [Extra defense-in-depth measure]

### References

- OWASP: [link to relevant OWASP page]
- CWE: [link to CWE entry]
- [Additional reference]

### Status

- [ ] Acknowledged
- [ ] Fix implemented
- [ ] Fix verified
