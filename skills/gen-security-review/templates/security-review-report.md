# Security Review: [Module/PR Name]

**Date**: [YYYY-MM-DD]
**Reviewer**: [Name]
**Scope**: [Files/modules reviewed]

## Summary

| Metric | Value |
|--------|-------|
| **Files reviewed** | [count] |
| **Overall verdict** | APPROVE / REQUEST CHANGES / BLOCK -- CRITICAL ISSUES |
| **Risk level** | CRITICAL / HIGH / MEDIUM / LOW / CLEAN |
| **Findings** | [X] critical, [X] high, [X] medium, [X] low, [X] info |

## Security Context

| Property | Value |
|----------|-------|
| **Application type** | API / web app / microservice / CLI / library |
| **Auth model** | JWT / session / OAuth / API keys / none |
| **Data sensitivity** | PII / financial / health records / low |
| **Trust boundaries** | [Where external input enters] |
| **Existing controls** | [WAF, rate limiting, CORS, CSP, etc.] |

## Findings

### CRITICAL

> Actively exploitable. Block merge. Fix immediately.

#### [C-001] [OWASP-ID] Title

- **Location**: `file/path.ext:line`
- **Vulnerability**: What the flaw is and how it works.
- **Impact**: What an attacker can achieve (data breach, RCE, privilege escalation).
- **Exploitation scenario**: Step-by-step how an attacker would exploit this.
- **Fix**:

```language
// Before (vulnerable):
vulnerable_code_here

// After (secure):
fixed_code_here
```

- **Reference**: CWE-XXX / OWASP A0X

---

### HIGH

> Exploitable with effort. Block merge. Fix before deploy.

#### [H-001] [OWASP-ID] Title

- **Location**: `file/path.ext:line`
- **Vulnerability**: Description.
- **Impact**: Exploitation scenario.
- **Fix**:

```language
// Before (vulnerable):
vulnerable_code_here

// After (secure):
fixed_code_here
```

- **Reference**: CWE-XXX / OWASP A0X

---

### MEDIUM

> Defense gap. Fix before release.

- **[M-001]** `file/path.ext:line` -- Description. **Fix**: Suggestion. (OWASP A0X)
- **[M-002]** `file/path.ext:line` -- Description. **Fix**: Suggestion. (OWASP A0X)

---

### LOW

> Hardening opportunity. Track as security debt.

- **[L-001]** `file/path.ext:line` -- Description. **Fix**: Suggestion.
- **[L-002]** `file/path.ext:line` -- Description. **Fix**: Suggestion.

---

### INFO

> Best practice suggestion. Optional improvement.

- **[I-001]** `file/path.ext:line` -- Description. **Suggestion**: Improvement.

---

## OWASP Top 10 Coverage

| # | Category | Status | Notes |
|---|----------|--------|-------|
| A01 | Broken Access Control | Checked / N/A | |
| A02 | Cryptographic Failures | Checked / N/A | |
| A03 | Injection | Checked / N/A | |
| A04 | Insecure Design | Checked / N/A | |
| A05 | Security Misconfiguration | Checked / N/A | |
| A06 | Vulnerable Components | Checked / N/A | |
| A07 | Auth Failures | Checked / N/A | |
| A08 | Data Integrity Failures | Checked / N/A | |
| A09 | Logging Failures | Checked / N/A | |
| A10 | SSRF | Checked / N/A | |

## Additional Checks

| Category | Status | Notes |
|----------|--------|-------|
| File uploads | Checked / N/A | |
| Race conditions | Checked / N/A | |
| Cryptography | Checked / N/A | |
| Error handling | Checked / N/A | |
| Frontend-specific | Checked / N/A | |
| IaC / Config | Checked / N/A | |

## Recommendations

Ordered by priority (most critical first):

1. **[CRITICAL]** [Recommendation]
2. **[HIGH]** [Recommendation]
3. **[MEDIUM]** [Recommendation]
4. **[LOW]** [Recommendation]

## Positive Observations

> Acknowledge good security practices found during review.

- [Good practice observed]
- [Good practice observed]

## Follow-Up Actions

- [ ] [Action item with owner and deadline]
- [ ] [Action item with owner and deadline]
- [ ] Re-review after fixes applied
