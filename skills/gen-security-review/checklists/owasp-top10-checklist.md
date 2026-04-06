# OWASP Top 10 Security Review Checklist

Use this checklist during code review to ensure all OWASP Top 10 (2021) categories are systematically evaluated.

## A01: Broken Access Control

- [ ] All endpoints enforce server-side authorization (not just client-side)
- [ ] Object references validated against ownership (no IDOR: `/api/orders/:id` checks user ownership)
- [ ] Role/permission checks on every privileged operation
- [ ] CORS configured with specific origins (no `Access-Control-Allow-Origin: *` with credentials)
- [ ] Directory listing disabled
- [ ] Access denied by default — explicit grants required

## A02: Cryptographic Failures

- [ ] No hardcoded secrets (API keys, passwords, tokens) in source code
- [ ] Passwords hashed with bcrypt/scrypt/argon2 (not MD5/SHA1/plain SHA256)
- [ ] Sensitive data encrypted at rest and in transit
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] No sensitive data in URLs (tokens, PII in query parameters)
- [ ] TLS enforced for all connections (HTTPS, encrypted internal comms)

## A03: Injection

- [ ] SQL queries use parameterized statements (no string concatenation)
- [ ] NoSQL queries use typed queries (no user input in `$where`, `$regex`)
- [ ] No user input in shell commands (`exec()`, `system()`, `os.popen()`)
- [ ] Server-side templates use auto-escaping (no raw user input)
- [ ] HTML output uses context-aware encoding (no XSS)
- [ ] Log entries sanitize newlines and control characters
- [ ] LDAP, XML, XPath queries parameterized

## A04: Insecure Design

- [ ] No mass assignment — allowlists for accepted fields on model updates
- [ ] Rate limiting on authentication, expensive, and public endpoints
- [ ] Input validation schemas defined (request bodies validated against structure)
- [ ] Race conditions protected with locking (balance checks, inventory, coupons)
- [ ] CSRF protection on all state-changing operations
- [ ] Business logic reviewed for abuse scenarios

## A05: Security Misconfiguration

- [ ] Debug mode disabled in production (`DEBUG=False`)
- [ ] Default credentials changed (Django `SECRET_KEY`, Rails `secret_key_base`)
- [ ] Admin/debug/health endpoints require authentication or are not exposed
- [ ] Unnecessary features disabled (directory listing, unused HTTP methods)
- [ ] Security headers present:
  - [ ] `Strict-Transport-Security` (HSTS)
  - [ ] `X-Content-Type-Options: nosniff`
  - [ ] `Content-Security-Policy`
  - [ ] `X-Frame-Options` or CSP `frame-ancestors`
- [ ] Error messages are generic to clients (no stack traces or SQL in responses)

## A06: Vulnerable and Outdated Components

- [ ] Dependency audit run (`npm audit`, `pip audit`, `mvn dependency-check`, `govulncheck`)
- [ ] No known CVEs in direct or transitive dependencies
- [ ] Dependencies pinned to exact versions (no `*` or `latest`)
- [ ] No abandoned packages (2+ years without updates with unresolved issues)
- [ ] Container base images up to date

## A07: Identification and Authentication Failures

- [ ] Password policy enforces minimum length and complexity
- [ ] Brute-force protection on login/reset/OTP endpoints
- [ ] Sessions: unpredictable IDs, expiration set, invalidated on logout
- [ ] JWT: `alg: none` rejected, secret not in code, `exp` claim present, reasonable lifetime
- [ ] Passwords stored with proper hashing (never reversible encoding)
- [ ] Multi-factor authentication supported for sensitive operations (if applicable)

## A08: Software and Data Integrity Failures

- [ ] No unsafe deserialization of user input (`pickle.loads()`, Java `ObjectInputStream`, PHP `unserialize()`)
- [ ] Deserialized data validated against schema or signature
- [ ] Software/config updates verified with signatures
- [ ] CI/CD pipeline integrity protected (signed commits, protected branches)

## A09: Security Logging and Monitoring Failures

- [ ] Authentication events logged (login, logout, failed attempts)
- [ ] Authorization failures logged
- [ ] Data modification events logged (create, update, delete)
- [ ] No sensitive data in logs (passwords, tokens, PII)
- [ ] Correlation IDs present for cross-service request tracing
- [ ] Log format supports automated analysis (structured logging)

## A10: Server-Side Request Forgery (SSRF)

- [ ] User-supplied URLs validated against allowlist before fetching
- [ ] No requests to internal addresses from user input (`localhost`, `169.254.169.254`, RFC1918 ranges)
- [ ] URL schemes restricted (only `http`/`https`, no `file://`, `gopher://`)
- [ ] Webhooks verify source signatures
- [ ] Response data from fetched URLs sanitized before returning to users

## Additional Checks

### File Uploads
- [ ] File type validated by content (magic bytes), not just extension
- [ ] File size limits enforced
- [ ] Uploaded files have no execution permissions
- [ ] Files stored outside web root or in object storage

### Frontend-Specific
- [ ] No `dangerouslySetInnerHTML` without DOMPurify sanitization
- [ ] No `eval()`, `new Function()`, or `document.write()` with user input
- [ ] `postMessage` origin validated
- [ ] Subresource Integrity (SRI) on third-party scripts

### Infrastructure as Code
- [ ] IAM roles follow least privilege principle
- [ ] No public S3 buckets or equivalent storage
- [ ] Security groups restrict inbound access to required ports only
- [ ] Secrets managed via secret manager (not environment files in repo)

### Race Conditions
- [ ] Financial operations use database-level locking
- [ ] Inventory/quota checks use atomic operations
- [ ] Time-of-check to time-of-use (TOCTOU) vulnerabilities addressed

### Cryptography
- [ ] Strong algorithms used (AES-256-GCM, RSA-2048+, ECDSA P-256+)
- [ ] No ECB mode for block ciphers
- [ ] Proper IV/nonce generation (random, never reused)
- [ ] Key rotation policy documented
