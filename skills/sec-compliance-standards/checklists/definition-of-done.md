# Definition of Done: Security Compliance Standards

All criteria must pass for the compliance assessment to be considered complete.

## Framework Applicability

- [ ] All four frameworks (GDPR, HIPAA, SOC2, PCI-DSS) explicitly evaluated for applicability
- [ ] Each determination includes rationale referencing specific data types or processing activities
- [ ] Geographic scope of data subjects documented
- [ ] Distribution model documented

## Data Classification

- [ ] Every database table has a documented classification level (PUBLIC/INTERNAL/CONFIDENTIAL/RESTRICTED)
- [ ] Every API endpoint's request/response DTOs have documented classification levels
- [ ] No unclassified data entities remain
- [ ] Data classification register is complete and uses standard template
- [ ] CONFIDENTIAL and RESTRICTED entities have documented retention periods
- [ ] CONFIDENTIAL and RESTRICTED entities have documented encryption requirements

## GDPR Controls (if applicable)

- [ ] Lawful basis documented for every personal data processing operation
- [ ] Consent mechanism is granular, with records including timestamp, version, IP, user agent, consent text
- [ ] Consent withdrawal mechanism exists and is effective within 24 hours
- [ ] No pre-checked consent checkboxes
- [ ] Consent is not bundled with terms of service
- [ ] Data subject rights implemented: access, rectification, erasure, portability, restriction, objection
- [ ] Data minimization verified: only necessary data collected
- [ ] Privacy by design patterns in place: pseudonymization, retention enforcement, consent-gated processing
- [ ] No PII in URL query parameters

## HIPAA Controls (if applicable)

- [ ] PHI encrypted with AES-256 at rest and TLS 1.2+ in transit
- [ ] Role-based access control with minimum necessary principle
- [ ] Audit trail records all PHI access with 6-year retention
- [ ] No PHI identifiers in application log messages
- [ ] API endpoints return purpose-specific DTOs, not full patient records
- [ ] All third-party services handling PHI have signed BAAs
- [ ] Breach notification process documented

## SOC2 Controls (if applicable)

- [ ] All code changes via PR with at least one reviewer
- [ ] No direct commits to main/production branches
- [ ] CI/CD pipeline includes security scanning gates
- [ ] Unique user accounts with MFA for production access
- [ ] Quarterly access reviews with evidence of revocation
- [ ] Health endpoints checked every 30 seconds
- [ ] Alerting configured for error rates, latency, and auth failures
- [ ] Incident response runbooks linked to alerts

## PCI-DSS Controls (if applicable)

- [ ] CVV, full track data, and PIN are NEVER stored after authorization
- [ ] PAN encrypted at rest with AES-256 and separate key management
- [ ] PAN masked in all displays (first 6, last 4 only)
- [ ] Cardholder data transmitted only over TLS 1.2+
- [ ] All access to cardholder data logged with 1-year retention
- [ ] Tokenization implemented (application never handles raw card numbers)
- [ ] CDE isolated in separate network segment/VPC
- [ ] Quarterly penetration testing of CDE boundaries

## Cross-Cutting

- [ ] Unified audit logging implemented with required schema
- [ ] Audit logs are append-only with tamper-evident storage
- [ ] No actual sensitive data values in audit logs
- [ ] Audit log retention meets all applicable framework minimums
- [ ] Error handling follows fail-closed principles
- [ ] No production data in non-production environments
- [ ] Strictest regulation applied for multi-jurisdiction data

## Deliverables

- [ ] Compliance matrix produced and complete
- [ ] Data classification register produced and complete
- [ ] Gap analysis documented with severity and SLAs
- [ ] Remediation plan produced for all FAIL gaps
- [ ] Governance audit trail entries logged for all evaluations
- [ ] Overall compliance status determined (PASS/CONDITIONAL PASS/FAIL)
