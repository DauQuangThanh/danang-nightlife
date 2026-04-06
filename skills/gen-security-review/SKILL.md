---
name: gen-security-review
description: "Reviews source code for security vulnerabilities including OWASP Top 10, injection flaws, broken authentication, and sensitive data exposure. Use when reviewing PRs for security, auditing services before deployment, hardening APIs, or when user mentions security review, vulnerability check, OWASP, or secure coding."
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "1.1.0"
  last_updated: "2026-02-08"
  category: security-review
  tags: "security, owasp, vulnerability, injection, authentication, authorization, code-review"
---

# General Security Review

## Overview

This skill reviews source code across any language, framework, or tier (backend, frontend, CLI, infrastructure-as-code) for security vulnerabilities. It systematically checks for OWASP Top 10 risks, injection flaws, broken authentication, sensitive data exposure, and insecure configurations. The goal is to catch security issues before they reach production -- not to replace penetration testing, but to ensure the code itself follows secure coding practices.

## When to Use

- Reviewing pull requests or merge requests for security concerns
- Auditing services or applications before deployment or release
- Hardening API endpoints and web interfaces against common attack vectors
- Assessing existing codebases for security debt
- Validating authentication, authorization, and data handling logic
- When user mentions "security review", "vulnerability check", "OWASP", or "secure coding"

## Prerequisites

- Access to the source code files to review
- Understanding of the project's primary language and framework (detected automatically)

## Instructions

### Step 1: Establish Security Context

Before reviewing code, gather context:

1. **Application type**: API service, web application, microservice, CLI tool, serverless function, library?
2. **Authentication model**: JWT, session-based, OAuth, API keys, none (internal tool)?
3. **Data sensitivity**: Does it handle PII, financial data, health records, credentials?
4. **Trust boundaries**: Where does external input enter? What services are trusted?
5. **Existing controls**: WAF, rate limiting, CORS policy, CSP headers?

Read configuration files to understand the security posture:

- Environment/config files (`.env.example`, `config/`, `settings.py`, `application.yml`)
- Auth middleware or guards
- CORS and security header configuration
- Dependency manifest (`package.json`, `requirements.txt`, `pom.xml`, `go.mod`, `.csproj`)

### Step 2: Systematic Vulnerability Scan

Review every file against the OWASP Top 10 (2021) plus additional checks:

#### 2.1 Broken Access Control (A01)

Check for:

- **Missing authorization checks**: Endpoints or routes accessible without verifying permissions
- **IDOR**: Accessing resources by ID without ownership validation (`/api/orders/123` returns any user's order)
- **Privilege escalation**: Regular users accessing admin functionality or modifying roles
- **Missing function-level access control**: No role/permission checks on the server side
- **CORS misconfiguration**: `Access-Control-Allow-Origin: *` with credentials
- **Client-side-only auth**: Authorization enforced only in UI, not server/API

#### 2.2 Cryptographic Failures (A02)

Check for:

- **Hardcoded secrets**: API keys, passwords, tokens in source code
- **Weak hashing**: MD5, SHA1, or plain SHA256 for passwords (use bcrypt, scrypt, argon2)
- **Unencrypted sensitive data**: PII or credentials stored in plaintext
- **Sensitive data in logs**: Logging request bodies with passwords, tokens, or PII
- **Sensitive data in URLs**: Tokens or PII in query parameters
- **Missing transport security**: HTTP instead of HTTPS, no TLS for internal services

#### 2.3 Injection (A03)

Trace every external input from entry point to consumption:

| Type | Red Flag | Secure Pattern |
|---|---|---|
| SQL | String concatenation in queries | Parameterized queries / prepared statements |
| NoSQL | User input in `$where`, `$regex`, query objects | Typed queries, input validation |
| Command | User input in `exec()`, `system()`, `os.popen()` | Avoid shell; use libraries. Whitelist if unavoidable |
| Template (SSTI) | Raw user input in server-side templates | Auto-escaping templates |
| XSS | User input rendered without escaping in HTML/JS | Context-aware output encoding, CSP headers |
| Log | User input in logs without sanitization | Sanitize newlines and control characters |

**Key rule**: If external input reaches a query, command, template, or DOM without parameterization or validation, flag it.

#### 2.4 Insecure Design (A04)

Check for:

- **Mass assignment**: Accepting all request fields into model updates without allowlist
- **Missing rate limiting**: No throttling on auth, expensive, or public endpoints
- **No input validation schema**: Request bodies accepted without structure validation
- **Business logic flaws**: Race conditions in balance checks, coupon redemption without locking
- **Missing CSRF protection**: State-changing operations without CSRF tokens

#### 2.5 Security Misconfiguration (A05)

Check for:

- **Debug mode in production**: `DEBUG=True`, verbose errors exposing stack traces or SQL
- **Default credentials**: Unchanged framework secrets (Django `SECRET_KEY`, Rails `secret_key_base`)
- **Exposed endpoints**: Health checks, metrics, debug routes without authentication
- **Unnecessary features**: Directory listing, unused HTTP methods, open admin consoles
- **Missing security headers**: `Strict-Transport-Security`, `X-Content-Type-Options`, `Content-Security-Policy`

#### 2.6 Vulnerable Components (A06)

Check for:

- **Known vulnerable packages**: Recommend `npm audit`, `pip audit`, `mvn dependency-check`, `govulncheck`
- **Outdated dependencies**: Major versions behind on security-critical packages
- **Unpinned versions**: Using `*` or `latest` instead of exact versions
- **Abandoned packages**: No updates in 2+ years with unresolved security issues

#### 2.7 Authentication Failures (A07)

Check for:

- **Weak password policies**: No minimum length or complexity requirements
- **No brute-force protection**: Missing rate limiting on login, reset, OTP endpoints
- **Insecure session management**: Predictable IDs, no expiration, no invalidation on logout
- **JWT weaknesses**: `alg: none` accepted, secret in code, no `exp`, excessive token lifetime
- **Plaintext password storage**: Any reversible encoding instead of proper hashing

#### 2.8 Data Integrity Failures (A08)

Check for:

- **Unsafe deserialization**: `pickle.loads()`, Java `ObjectInputStream`, PHP `unserialize()` on user input
- **Missing integrity checks**: Deserialized data not validated against schema or signature
- **Unsigned updates**: Software or config updates without verification

#### 2.9 Logging & Monitoring Failures (A09)

Check for:

- **Missing audit logs**: No logging of auth events, authorization failures, data modifications
- **Sensitive data in logs**: Passwords, tokens, PII written to log output
- **No request tracing**: Missing correlation IDs for cross-service tracking

#### 2.10 SSRF (A10)

Check for:

- **User-controlled URLs**: Fetching URLs from users without validation (webhooks, avatars, imports)
- **Missing allowlists**: No restriction on target hosts, ports, or protocols
- **Internal access**: User input triggering requests to `localhost`, `169.254.169.254`, or internal services

#### 2.11 Additional Checks

| Category | What to Check |
|---|---|
| File uploads | Type validation (not just extension), size limits, no execution permissions |
| Race conditions | TOCTOU in balance/inventory without locking |
| Cryptography | Strong algorithms (AES-256, RSA-2048+), no ECB mode, proper IV/nonce |
| Error handling | Generic messages to clients, detailed errors only in logs |
| Frontend-specific | DOM-based XSS, `dangerouslySetInnerHTML`, `eval()`, insecure postMessage |
| IaC / Config | Overly permissive IAM roles, public S3 buckets, open security groups |

### Step 3: Classify Findings

| Severity | Meaning | Action |
|---|---|---|
| **CRITICAL** | Actively exploitable: injection, auth bypass, RCE, exposed secrets | Block merge. Fix immediately. |
| **HIGH** | Exploitable with effort: IDOR, weak crypto, missing auth on sensitive endpoints | Block merge. Fix before deploy. |
| **MEDIUM** | Defense gap: missing rate limiting, verbose errors, insecure headers | Fix before release. |
| **LOW** | Hardening: missing audit logs, unpinned deps, minor misconfig | Track as security debt. |
| **INFO** | Best practice suggestion, no immediate risk | Optional improvement. |

### Step 4: Generate Security Review Report

```markdown
# Security Review: [Module/PR Name]

## Summary
- **Files reviewed**: [count]
- **Overall verdict**: [APPROVE / REQUEST CHANGES / BLOCK -- CRITICAL ISSUES]
- **Risk level**: [CRITICAL / HIGH / MEDIUM / LOW / CLEAN]
- **Findings**: [X critical, X high, X medium, X low, X info]

## Security Context
- **Application type**: [API / web app / microservice / CLI / library]
- **Auth model**: [JWT / session / OAuth / none]
- **Data sensitivity**: [PII / financial / low]

## Findings

### CRITICAL
- **[OWASP-ID]** [file:line] **Title**
  - **Vulnerability**: What the flaw is.
  - **Impact**: What an attacker can do.
  - **Fix**: Concrete before/after code.

### HIGH
- **[OWASP-ID]** [file:line] **Title**
  - **Vulnerability**: Description.
  - **Impact**: Exploitation scenario.
  - **Fix**: Concrete code change.

### MEDIUM
- **[OWASP-ID]** [file:line] **Title** -- Description. **Fix**: Suggestion.

### LOW / INFO
- [file:line] Description. **Fix**: Suggestion.

## OWASP Coverage
| Category | Status | Notes |
|---|---|---|
| A01 Broken Access Control | [Checked/N-A] | |
| A02 Cryptographic Failures | [Checked/N-A] | |
| A03 Injection | [Checked/N-A] | |
| A04 Insecure Design | [Checked/N-A] | |
| A05 Security Misconfiguration | [Checked/N-A] | |
| A06 Vulnerable Components | [Checked/N-A] | |
| A07 Auth Failures | [Checked/N-A] | |
| A08 Data Integrity Failures | [Checked/N-A] | |
| A09 Logging Failures | [Checked/N-A] | |
| A10 SSRF | [Checked/N-A] | |

## Recommendations
[Ordered list, most critical first.]
```

### Step 5: Provide Actionable Remediation

For every finding:

1. **Exact location**: File path and line number.
2. **Explain the vulnerability**: What is the flaw and how can it be exploited?
3. **Show the impact**: Data breach, privilege escalation, RCE?
4. **Provide the fix**: Before/after code -- not just "sanitize input".
5. **Reference**: OWASP category or CWE ID when applicable.

## Examples

### Example 1: SQL Injection (CRITICAL)

```python
# CRITICAL [A03] src/repositories/user_repo.py:42
# SQL Injection via string concatenation

# Before (vulnerable):
def get_user(self, username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    return self.db.execute(query).fetchone()

# After (parameterized):
def get_user(self, username):
    query = "SELECT * FROM users WHERE username = :username"
    return self.db.execute(query, {"username": username}).fetchone()
# Impact: Attacker extracts entire database via ' OR '1'='1' --
```

### Example 2: Broken Access Control -- IDOR (HIGH)

```javascript
// HIGH [A01] src/controllers/orderController.js:28
// Any authenticated user can view any order -- no ownership check

// Before (vulnerable):
app.get('/api/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.id);
  res.json(order);
});

// After (ownership validated):
app.get('/api/orders/:id', authenticate, async (req, res) => {
  const order = await Order.findById(req.params.id);
  if (!order) return res.status(404).json({ error: 'Not found' });
  if (order.userId !== req.user.id) return res.status(403).json({ error: 'Forbidden' });
  res.json(order);
});
// Impact: Attacker enumerates and accesses all orders by iterating IDs
```

### Example 3: DOM-based XSS in Frontend (HIGH)

```jsx
// HIGH [A03] src/components/UserProfile.tsx:15
// User-supplied HTML rendered without sanitization

// Before (vulnerable):
function UserProfile({ bio }) {
  return <div dangerouslySetInnerHTML={{ __html: bio }} />;
}

// After (sanitized):
import DOMPurify from 'dompurify';
function UserProfile({ bio }) {
  return <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(bio) }} />;
}
// Impact: Attacker injects script via bio field, stealing session tokens
```

## Key Rules

1. **Trace all input**: Follow every external input to where it is consumed. Flag unvalidated paths.
2. **Assume attackers know your code**: Security through obscurity is not security.
3. **Defense in depth**: One control failing should not compromise the system.
4. **Least privilege**: Code should enforce minimum necessary permissions.
5. **Fail securely**: Errors deny access by default, never grant it.
6. **Every finding needs a fix**: Provide remediation code, not just descriptions.
7. **Severity matters**: Clearly distinguish critical from nice-to-have. Do not cry wolf.
8. **Check full OWASP Top 10**: Use the coverage table to ensure completeness.
9. **Secrets in environment only**: Never in source code, committed configs, or logs.
10. **Validate at boundaries**: Trust internal code; validate at every system boundary.

## Edge Cases

### Case 1: Internal-Only Service

**Handling**: Still review for injection and access control -- internal services get compromised through lateral movement. Reduce severity for missing security headers but still flag auth and data exposure.

### Case 2: Legacy Codebase with Known Vulnerabilities

**Handling**: Focus on new/changed code. Document existing vulnerabilities as security debt separately. Do not block current PR for pre-existing issues unless changes worsen the posture.

### Case 3: Third-Party Integrations (Webhooks, Callbacks)

**Handling**: Treat all incoming webhook data as untrusted. Verify signatures, validate payloads. Flag missing webhook signature verification as HIGH.

## Error Handling

### Error: Cannot Determine Auth Model

**Action**: Ask the user to describe the authentication mechanism. Check for auth middleware, JWT libraries, or session stores in dependencies.

### Error: No Configuration Files Accessible

**Action**: Proceed with code-level review only. Note in report that configuration review was not possible.

### Error: Review Scope Too Large (100+ Files)

**Action**: Prioritize: (1) auth/authz code, (2) input handling (controllers/routes), (3) data access layer, (4) configuration. Document what was reviewed and what was skipped.

## Checklists

Use the checklists in `checklists/` for systematic review:

- **[owasp-top10-checklist.md](checklists/owasp-top10-checklist.md)**: Full OWASP Top 10 checklist with per-category items covering access control, cryptography, injection, insecure design, misconfiguration, vulnerable components, authentication, data integrity, logging, and SSRF — plus additional checks for file uploads, frontend, IaC, race conditions, and cryptography
- **[pre-review-checklist.md](checklists/pre-review-checklist.md)**: Pre-review preparation checklist for context gathering, access verification, scope definition, and review parameters

## Templates

Use the templates in `templates/` for consistent reporting:

- **[security-review-report.md](templates/security-review-report.md)**: Full security review report template with summary, findings by severity, OWASP coverage table, recommendations, and follow-up actions
- **[finding-template.md](templates/finding-template.md)**: Individual finding template with severity, impact matrix, exploitation scenario, remediation code, and status tracking

## Success Criteria

Review is complete when:

- [ ] All files in scope have been reviewed
- [ ] All OWASP Top 10 categories checked (coverage table filled)
- [ ] Every finding includes file path, line, description, impact, and fix
- [ ] Findings categorized by severity (CRITICAL / HIGH / MEDIUM / LOW / INFO)
- [ ] CRITICAL and HIGH findings include exploitation scenario
- [ ] All fixes show concrete before/after code
- [ ] Security risk level assigned
- [ ] Overall verdict given (APPROVE / REQUEST CHANGES / BLOCK)
- [ ] Report follows structured format from Step 4
