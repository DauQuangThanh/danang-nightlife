# Step 6: Validate Compliance

## RULES

- Validation MUST cover every applicable framework identified in Step 1.
- A framework is PASS only if ALL its required controls are PASS.
- A framework is FAIL if ANY required control is FAIL.
- A framework is CONDITIONAL PASS if all required controls pass but WARN items remain.
- The overall assessment is FAIL if ANY applicable framework is FAIL.
- All validation results MUST be logged in the governance audit trail format.

## INSTRUCTIONS

1. For each applicable framework, aggregate the control assessment results from Step 3 and the gap analysis from Step 4.

2. Determine the framework-level compliance status:
   - **PASS**: All required controls are implemented with evidence. No FAIL gaps remain.
   - **CONDITIONAL PASS**: All required controls pass, but one or more WARN items exist with documented accepted risks.
   - **FAIL**: One or more required controls are not implemented or have unresolved FAIL gaps.

3. Produce the compliance matrix using the template at [../templates/compliance-matrix.md](../templates/compliance-matrix.md). Fill in:
   - Every control assessed
   - Status (PASS/FAIL/WARN)
   - Evidence reference (file path, configuration, documentation)
   - Gap ID (if applicable)
   - Remediation reference (if applicable)

4. Produce the overall compliance assessment:
   - List of applicable frameworks with status
   - Number of controls assessed per framework
   - Number of PASS / FAIL / WARN per framework
   - Overall status (PASS / CONDITIONAL PASS / FAIL)
   - Summary of critical and high gaps remaining

5. Log all governance evaluations in the audit trail format:
   ```yaml
   - rule: <rule-name>
     result: PASS | FAIL | WARN
     regulation: GDPR | HIPAA | SOC2 | PCI-DSS
     files: ["<affected-file-paths>"]
     detail: "<description of finding>"
     remediation: "<remediation hint for failures>"
   ```

6. Verify the compliance review checklist for the PR:
   - [ ] Data classification verified for all new data entities
   - [ ] Lawful basis documented for any new personal data processing
   - [ ] Consent mechanism implemented for optional data collection
   - [ ] Data subject rights endpoints updated if new PII fields added
   - [ ] Encryption applied to CONFIDENTIAL and RESTRICTED data at rest and in transit
   - [ ] Audit logging implemented for all access to sensitive data
   - [ ] Access control enforced with minimum necessary principle
   - [ ] Data retention period defined and automated cleanup scheduled
   - [ ] No sensitive data in log messages (PII, PHI, PAN, secrets)
   - [ ] Third-party services handling sensitive data have appropriate agreements (DPA, BAA)
   - [ ] Error responses do not expose sensitive data or internal details

7. If the overall status is FAIL, ensure the remediation plan from Step 5 is attached to the output with clear ownership and SLAs.

## VALIDATION

- [ ] Compliance matrix is complete for all applicable frameworks
- [ ] Every control has a documented status with evidence
- [ ] Overall compliance status is determined
- [ ] Governance audit trail entries are produced for all evaluations
- [ ] PR compliance checklist is completed
- [ ] If FAIL, remediation plan is attached with SLAs and ownership

Workflow complete. Validate output against [../checklists/definition-of-done.md](../checklists/definition-of-done.md) and produce final deliverables using the templates.
