# Compliance Matrix

**Project**: [PROJECT NAME]
**Date**: [YYYY-MM-DD]
**Assessor**: [AGENT ID / REVIEWER NAME]
**Commit SHA**: [COMMIT SHA]
**Overall Status**: [PASS / CONDITIONAL PASS / FAIL]

---

## Applicable Frameworks

| Framework   | Applicable | Rationale                          | Status |
| ----------- | ---------- | ---------------------------------- | ------ |
| GDPR        | YES / NO   | [Why this framework applies or not]| [PASS/FAIL/N/A] |
| HIPAA       | YES / NO   | [Why this framework applies or not]| [PASS/FAIL/N/A] |
| SOC2 Type II| YES / NO   | [Why this framework applies or not]| [PASS/FAIL/N/A] |
| PCI-DSS v4.0| YES / NO   | [Why this framework applies or not]| [PASS/FAIL/N/A] |

---

## GDPR Controls

| Control                          | Status      | Evidence                     | Gap ID | Remediation |
| -------------------------------- | ----------- | ---------------------------- | ------ | ----------- |
| Lawful basis documented          | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Granular consent mechanism       | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Consent withdrawal (24h SLA)     | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No pre-checked checkboxes        | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right of Access endpoint         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right to Rectification endpoint  | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right to Erasure endpoint        | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right to Portability endpoint    | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right to Restrict endpoint       | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Right to Object endpoint         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Data minimization                | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Pseudonymization                 | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Retention enforcement            | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No PII in URL parameters         | PASS/FAIL   | [file path or doc reference] | -      | -           |

---

## HIPAA Controls

| Control                          | Status      | Evidence                     | Gap ID | Remediation |
| -------------------------------- | ----------- | ---------------------------- | ------ | ----------- |
| PHI encryption at rest (AES-256) | PASS/FAIL   | [file path or doc reference] | -      | -           |
| PHI encryption in transit (TLS 1.2+)| PASS/FAIL| [file path or doc reference] | -      | -           |
| RBAC with minimum necessary      | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Audit trail (6-year retention)   | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No PHI in log messages           | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Purpose-specific DTOs            | PASS/FAIL   | [file path or doc reference] | -      | -           |
| BAAs with third parties          | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Breach notification process      | PASS/FAIL   | [file path or doc reference] | -      | -           |
| De-identification (Safe Harbor)  | PASS/FAIL   | [file path or doc reference] | -      | -           |

---

## SOC2 Type II Controls

| Control                          | Status      | Evidence                     | Gap ID | Remediation |
| -------------------------------- | ----------- | ---------------------------- | ------ | ----------- |
| PR-based code changes            | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No direct commits to main        | PASS/FAIL   | [file path or doc reference] | -      | -           |
| CI/CD with security scanning     | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Deployment approvals             | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Rollback procedures              | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Unique user accounts             | PASS/FAIL   | [file path or doc reference] | -      | -           |
| MFA for production access        | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Quarterly access reviews         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Least privilege (RBAC)           | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Service account rotation         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Health endpoint monitoring       | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Error rate alerting              | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Latency alerting                 | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Auth failure alerting            | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Incident response runbooks       | PASS/FAIL   | [file path or doc reference] | -      | -           |

---

## PCI-DSS v4.0 Controls

| Control                          | Status      | Evidence                     | Gap ID | Remediation |
| -------------------------------- | ----------- | ---------------------------- | ------ | ----------- |
| No CVV/track/PIN storage         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| PAN encrypted at rest (AES-256)  | PASS/FAIL   | [file path or doc reference] | -      | -           |
| PAN masked in displays           | PASS/FAIL   | [file path or doc reference] | -      | -           |
| TLS 1.2+ for cardholder data     | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Access logging (1-year retention)| PASS/FAIL   | [file path or doc reference] | -      | -           |
| Unique user IDs for CDE access   | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Need-to-know access restriction  | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Tokenization implemented         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| CDE network segmentation         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Quarterly penetration testing    | PASS/FAIL   | [file path or doc reference] | -      | -           |

---

## Cross-Cutting Controls

| Control                          | Status      | Evidence                     | Gap ID | Remediation |
| -------------------------------- | ----------- | ---------------------------- | ------ | ----------- |
| Unified audit log schema         | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Append-only audit logs           | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Tamper-evident log storage       | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No sensitive data in logs        | PASS/FAIL   | [file path or doc reference] | -      | -           |
| Fail-closed error handling       | PASS/FAIL   | [file path or doc reference] | -      | -           |
| No prod data in non-prod envs    | PASS/FAIL   | [file path or doc reference] | -      | -           |

---

## Gap Summary

| Gap ID  | Regulation | Severity | Control               | Status      | SLA         |
| ------- | ---------- | -------- | --------------------- | ----------- | ----------- |
| GAP-001 | [REG]      | Critical | [Control name]        | Open/Closed | [SLA]       |
| GAP-002 | [REG]      | High     | [Control name]        | Open/Closed | [SLA]       |

---

## Governance Audit Trail

```yaml
# Evaluation results
- rule: <rule-name>
  result: PASS | FAIL | WARN
  regulation: GDPR | HIPAA | SOC2 | PCI-DSS
  files: ["<affected-file-paths>"]
  detail: "<description of finding>"
  remediation: "<remediation hint for failures>"
```
