# Step 3: Assess Controls

## RULES

- Assess controls ONLY for frameworks identified as applicable in Step 1.
- Every control assessment must reference specific code, configuration, or documentation as evidence.
- A control is PASS only if evidence exists. No assumed compliance.
- Code patterns must be verified in the actual codebase, not assumed from architecture docs alone.

## INSTRUCTIONS

### 3A. GDPR Controls (if applicable)

1. **Lawful basis for processing**: Verify that every data processing operation has a documented lawful basis:

   | Lawful Basis       | When to Use                                          | Code Pattern                                |
   | ------------------ | ---------------------------------------------------- | ------------------------------------------- |
   | Consent            | Optional data collection (marketing, analytics)      | Explicit opt-in with granular consent records |
   | Contract           | Data needed to fulfill a service agreement           | Process only data required for the service  |
   | Legal Obligation   | Tax records, regulatory reporting                    | Retain for required period, then delete     |
   | Legitimate Interest| Security logging, fraud prevention                   | Document the interest assessment            |

2. **Consent management**: Verify these patterns exist:
   - Granular consent: separate consent for each processing purpose
   - Consent records: store timestamp, version, IP, user agent, and consent text
   - Withdrawal: easy mechanism to withdraw consent, effective within 24 hours
   - Pre-checked boxes: NEVER pre-check consent checkboxes
   - Bundled consent: NEVER bundle consent with terms of service acceptance

3. **Data subject rights**: Verify implementation of each right:

   | Right                 | Implementation Requirement                                         | Response SLA |
   | --------------------- | ------------------------------------------------------------------ | ------------ |
   | Right of Access       | Export all personal data in machine-readable format (JSON/CSV)     | 30 days      |
   | Right to Rectification| Allow users to correct their personal data via self-service or API | 30 days      |
   | Right to Erasure      | Delete or anonymize all personal data across all systems           | 30 days      |
   | Right to Portability  | Export data in structured, commonly used format                    | 30 days      |
   | Right to Restrict     | Flag data for restricted processing, stop active processing       | 72 hours     |
   | Right to Object       | Opt-out of processing for specific purposes (e.g., marketing)     | 72 hours     |

4. **Data minimization**: Check that:
   - Only data strictly necessary for the stated purpose is collected
   - Raw IP addresses are not stored when anonymized analytics suffice
   - Identifiers are truncated or hashed where full values are not required
   - Default data retention periods are set with auto-delete for expired data
   - Data fields are reviewed annually and unused collections removed

5. **Privacy by design code patterns**: Look for:
   - Pseudonymization (e.g., `sha256(user_id + daily_salt)` with daily salt rotation)
   - Scheduled data retention enforcement jobs
   - Consent-gated processing (check consent status before processing)

### 3B. HIPAA Controls (if applicable)

1. **PHI safeguards**: Verify all three safeguard categories:

   | Safeguard Category | Requirements                                                          |
   | ------------------ | --------------------------------------------------------------------- |
   | Administrative     | Workforce training, access management procedures, incident response plan |
   | Physical           | Facility access controls, workstation security, device disposal        |
   | Technical          | Access control, audit controls, integrity controls, transmission security |

2. **PHI handling rules**: Verify:
   - Encryption: AES-256 at rest, TLS 1.2+ in transit -- no exceptions
   - Access control: Role-based with minimum necessary principle; all access logged
   - Audit trail: Records who accessed what PHI, when, and from where; retained for 6 years
   - De-identification: Safe Harbor method (remove 18 identifiers) or Expert Determination
   - Business associates: All third-party services handling PHI have a signed BAA
   - Breach notification: Process exists to report breaches affecting 500+ individuals within 60 days to HHS

3. **HIPAA-compliant logging**: Verify:
   - REQUIRED logged events: User ID, timestamp, action (read/write/delete), resource ID, source IP, user agent, success/failure status
   - FORBIDDEN in logs: Patient names, SSN, dates of birth, medical record numbers, diagnosis codes, treatment information, provider notes, any of the 18 HIPAA identifiers

4. **Minimum necessary standard**: Verify API endpoints return purpose-specific DTOs, not full records:
   - WRONG: `GET /patients/123` returning full record with SSN, diagnosis, address
   - CORRECT: `GET /patients/123/summary` returning only name and appointment date

### 3C. SOC2 Controls (if applicable)

1. **Trust service criteria**: Assess each criterion:

   | Criteria             | Focus Area                               | Code-Level Requirements                        |
   | -------------------- | ---------------------------------------- | ---------------------------------------------- |
   | Security             | Protection against unauthorized access   | Auth, encryption, firewall rules, vulnerability scanning |
   | Availability         | System uptime and performance            | Health checks, auto-scaling, disaster recovery  |
   | Processing Integrity | Complete and accurate data processing    | Input validation, reconciliation, error handling |
   | Confidentiality      | Protection of confidential information   | Encryption, access controls, data classification|
   | Privacy              | Personal information handling            | Consent, data minimization, retention policies  |

2. **Change management controls**: Verify:
   - All code changes via pull request with at least one reviewer
   - No direct commits to main/production branches
   - Automated CI/CD pipeline with security scanning gates
   - Deployment approvals required for production environments
   - Rollback procedures documented and tested quarterly

3. **Access control patterns**: Verify:
   - Unique user accounts (no shared credentials)
   - MFA for all production system access
   - Quarterly access reviews with evidence of revocation
   - Principle of least privilege enforced via RBAC
   - Service accounts with scoped permissions, rotated quarterly
   - Break-glass procedures documented for emergency access
   - Audit evidence: provisioning/deprovisioning logs, MFA enrollment records, quarterly review sign-offs, service account inventory with last-rotated dates

4. **Monitoring and alerting**: Verify:
   - Application health endpoints checked every 30 seconds
   - Alert on error rate exceeding 1% over 5-minute window
   - Alert on P99 latency exceeding SLA threshold
   - Alert on authentication failure rate spike (>10x baseline)
   - Incident response runbooks linked to each alert
   - Mean Time to Detect (MTTD) target: under 15 minutes

### 3D. PCI-DSS v4.0 Controls (if applicable)

1. **Cardholder data environment (CDE) scope**: Verify data handling against:

   | Data Element               | Storage Permitted | Must Encrypt | Must Mask in Display |
   | -------------------------- | ----------------- | ------------ | -------------------- |
   | Primary Account Number     | Yes (if needed)   | Yes          | Yes (show last 4)    |
   | Cardholder Name            | Yes               | Recommended  | No                   |
   | Service Code               | Yes               | Recommended  | No                   |
   | Expiration Date            | Yes               | Recommended  | No                   |
   | Full Track Data            | NEVER             | N/A          | N/A                  |
   | CVV/CVC                    | NEVER             | N/A          | N/A                  |
   | PIN / PIN Block            | NEVER             | N/A          | N/A                  |

2. **PCI-DSS code requirements**: Verify:
   - Never store CVV, full track data, or PIN after authorization
   - Encrypt PAN at rest with AES-256; separate key management
   - Mask PAN in all displays: show only first 6 and last 4 digits
   - Transmit cardholder data only over TLS 1.2+
   - Log all access to cardholder data; retain logs for 1 year (3 months online)
   - Unique IDs for all users accessing cardholder data
   - Restrict access on a need-to-know basis

3. **Tokenization**: Verify the preferred pattern:
   - Client sends card data directly to payment processor (Stripe, Braintree)
   - Payment processor returns a token
   - Application stores only the token, never the raw PAN
   - All subsequent operations use the token
   - This reduces PCI scope to SAQ-A or SAQ-A-EP

4. **Network segmentation**: Verify:
   - CDE isolated in a separate network segment / VPC
   - Firewall rules restrict traffic to only necessary ports and protocols
   - No direct internet access from CDE; use proxy/NAT gateway
   - Database servers in private subnets with no public IP
   - Quarterly network penetration testing of CDE boundaries

### 3E. Cross-Cutting Audit Logging

1. Verify a unified audit logging pattern is implemented with this schema:

   ```
   Audit Log Schema:
   {
     "event_id": "uuid",
     "timestamp": "ISO 8601 with timezone",
     "actor": {
       "user_id": "string",
       "role": "string",
       "ip_address": "string",
       "user_agent": "string"
     },
     "action": "CREATE | READ | UPDATE | DELETE | LOGIN | LOGOUT | EXPORT",
     "resource": {
       "type": "string (e.g., patient, payment, user)",
       "id": "string",
       "classification": "PUBLIC | INTERNAL | CONFIDENTIAL | RESTRICTED"
     },
     "outcome": "SUCCESS | FAILURE | DENIED",
     "metadata": {
       "fields_accessed": ["list of field names"],
       "reason": "optional justification for access",
       "changes": {"field": {"old": "...", "new": "..."}}
     }
   }
   ```

2. Verify audit log rules:
   - Append-only: no modification or deletion by application code
   - Retention: minimum 1 year (PCI-DSS), 6 years (HIPAA), or as required by local regulation
   - Storage: shipped to a separate, tamper-evident log storage (SIEM, immutable S3 bucket)
   - No actual sensitive data values in logs -- only metadata about access

3. Record the assessment result (PASS/FAIL/WARN) for each control with evidence references.

## VALIDATION

- [ ] All applicable framework controls have been assessed
- [ ] Each control assessment references specific code, configuration, or documentation as evidence
- [ ] Cross-cutting audit logging has been assessed
- [ ] GDPR consent patterns verified (if applicable)
- [ ] HIPAA PHI safeguards verified (if applicable)
- [ ] SOC2 trust criteria assessed (if applicable)
- [ ] PCI-DSS CDE scope verified (if applicable)
- [ ] Each control has a PASS/FAIL/WARN result recorded

Proceed to [./step-04-identify-gaps.md](step-04-identify-gaps.md)
