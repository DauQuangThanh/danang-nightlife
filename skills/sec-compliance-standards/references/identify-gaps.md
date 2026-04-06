# Step 4: Identify Gaps

## RULES

- Every FAIL result from Step 3 MUST be documented as a gap.
- Every WARN result MUST be evaluated and either escalated to a gap or documented as an accepted risk.
- Gaps MUST be checked against the banned patterns list. Banned pattern violations are automatically Critical severity.
- Architectural fitness functions MUST be evaluated and any failures documented as gaps.

## INSTRUCTIONS

1. Collect all FAIL and WARN results from Step 3 (Assess Controls).

2. For each FAIL result, create a gap entry with:
   - Gap ID (sequential, e.g., GAP-001)
   - Applicable regulation (GDPR, HIPAA, SOC2, PCI-DSS)
   - Control that failed
   - Description of the gap
   - Affected files or components
   - Current state vs. required state

3. For each WARN result, determine if it is:
   - A gap that needs remediation (escalate to FAIL)
   - An accepted risk with documented justification (record the justification)

4. Check all code against the banned patterns list. Flag any matches as Critical gaps:

   | Pattern                                    | Regulation | Alternative                                     |
   | ------------------------------------------ | ---------- | ----------------------------------------------- |
   | Storing CVV/PIN after authorization         | PCI-DSS    | Tokenize via payment processor                  |
   | Logging PHI identifiers in application logs | HIPAA      | Log resource ID only, never PHI fields          |
   | Pre-checked consent checkboxes              | GDPR       | Require explicit user action to consent         |
   | Shared service accounts for production      | SOC2       | Unique accounts with MFA and quarterly rotation |
   | PII in URL query parameters                 | GDPR       | Use POST body or encrypted path parameters      |
   | Unencrypted PII in database columns         | All        | Column-level or application-level encryption    |
   | Exporting user data without access check    | GDPR       | Verify requestor identity before data export    |
   | Indefinite data retention without policy    | All        | Define retention period and auto-purge schedule |

5. Evaluate architectural fitness functions and document any failures as gaps:
   - **Data Classification Coverage**: Every database table and API response DTO must have a documented classification. Unclassified entities are a gap.
   - **Encryption Verification**: All CONFIDENTIAL or RESTRICTED fields must be encrypted at rest. Unencrypted fields are a gap.
   - **Audit Log Completeness**: All endpoints accessing CONFIDENTIAL or RESTRICTED data must emit audit log events. Missing audit logging is a gap.
   - **Retention Policy Enforcement**: All data entities with a defined retention period must have an associated cleanup mechanism. Missing cleanup is a gap.
   - **Consent Gate Verification**: All processing of consent-based data must check consent status before processing. Missing consent checks are a gap.

6. Assign severity to each gap:
   - **Critical**: Banned pattern violation, active data exposure, or breach risk. SLA: 24 hours.
   - **High**: Missing required control for applicable regulation. SLA: 72 hours.
   - **Medium**: Control partially implemented or documentation gap. SLA: 1 sprint.
   - **Low**: Enhancement opportunity or best practice not yet adopted. SLA: backlog.

7. Document edge cases encountered:
   - Data migration projects: apply the same compliance controls to the migration pipeline
   - Third-party analytics: client-side analytics must respect consent preferences; defer script loading until consent is granted
   - Backup and disaster recovery: backups with sensitive data must be encrypted and subject to the same retention and access policies

## VALIDATION

- [ ] All FAIL results from Step 3 are documented as gaps
- [ ] All WARN results are either escalated or documented as accepted risks
- [ ] Banned patterns list has been checked against the codebase
- [ ] All architectural fitness functions have been evaluated
- [ ] Every gap has an assigned severity (Critical/High/Medium/Low)
- [ ] Every gap references the applicable regulation
- [ ] Every gap includes affected files or components

Proceed to [./step-05-generate-remediation-plan.md](step-05-generate-remediation-plan.md)
