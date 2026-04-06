---
name: sec-compliance-standards
description: "Performs GDPR, HIPAA, SOC2, and PCI-DSS compliance checks, data classification, control assessments, and audit readiness reviews. Generates compliance matrices, data classification registers, and remediation plans. Use when reviewing code for regulatory compliance, data privacy, or when user mentions GDPR, HIPAA, SOC2, PCI-DSS, data protection, or compliance audit."
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "3.0.0"
  last_updated: "2026-02-08"
  category: security
  tags: "compliance, gdpr, hipaa, soc2, pci-dss, data-protection, privacy, audit"
---

# Security Compliance Standards

## Overview

This skill performs regulatory compliance assessments for applications handling sensitive data. It evaluates code against GDPR, HIPAA, SOC2 Type II, and PCI-DSS v4.0 requirements, classifies data entities, assesses existing controls, identifies gaps, and produces prioritized remediation plans with specific code patterns. The output is a complete compliance posture assessment with pass/fail results.

## When to Use

- Reviewing code or PRs for regulatory compliance
- Classifying data entities (PII, PHI, financial, cardholder)
- Assessing GDPR consent management and data subject rights
- Auditing HIPAA PHI safeguards and access controls
- Validating SOC2 trust criteria and change management
- Verifying PCI-DSS cardholder data environment controls
- When user mentions "GDPR", "HIPAA", "SOC2", "PCI-DSS", "compliance", or "data protection"

## Prerequisites

- Access to source code, database schemas, and API definitions
- Data flow diagrams documenting sensitive data paths
- Understanding of which regulatory frameworks apply
- Organization's privacy policy and data processing agreements

## Governance Rules

1. Every data processing operation MUST have a documented lawful basis
2. All data MUST be classified as **PUBLIC**, **INTERNAL**, **CONFIDENTIAL**, or **RESTRICTED**
3. CONFIDENTIAL and RESTRICTED data MUST be encrypted at rest and in transit
4. Audit logs are **append-only** — no modification or deletion by application code
5. Never include actual sensitive data values in audit logs — only metadata
6. **Fail closed**: if compliance infrastructure is unavailable, deny processing of sensitive data
7. Never use production data in non-production environments
8. Apply the **strictest applicable regulation** when serving multiple jurisdictions
9. Remediation SLAs: **Critical 24h**, **High 72h**, **Medium 1 sprint**

## Instructions

### Step 1: Identify Applicable Frameworks

Evaluate ALL four frameworks before excluding any:

| Data Type | Framework Triggered |
|-----------|-------------------|
| PII (names, emails, IPs) | GDPR |
| PHI (health records, diagnoses) | HIPAA |
| Financial/customer data (SaaS) | SOC2 |
| Cardholder data (PAN, CVV) | PCI-DSS |

Document for each: applicable YES/NO, rationale, triggering data entities, geographic scope.

See [references/identify-applicable-frameworks.md](references/identify-applicable-frameworks.md) for detailed determination procedures.

### Step 2: Classify Data

Classify every data entity in the application:

| Level | Description | Handling Requirements |
|-------|-------------|----------------------|
| **PUBLIC** | Openly available | No special controls |
| **INTERNAL** | Business internal | Access control, no external sharing |
| **CONFIDENTIAL** | PII, contracts | Encryption at rest + transit, audit logging |
| **RESTRICTED** | PHI, PAN, SSN | End-to-end encryption, strict access, DLP, retention policies |

For CONFIDENTIAL/RESTRICTED: document retention period, encryption requirements, access controls, applicable regulation. Produce the data classification register using [templates/data-classification-register.md](templates/data-classification-register.md).

See [references/classify-data.md](references/classify-data.md) for complete classification procedures.

### Step 3: Assess Controls

Evaluate existing controls against each applicable framework. Key areas:

**GDPR**: Lawful basis, consent management (granular, no pre-checked boxes), data subject rights (access, rectification, erasure, portability), data minimization, privacy by design patterns.

**HIPAA**: PHI safeguards (administrative, physical, technical), encryption (AES-256 at rest, TLS 1.2+ in transit), access control with minimum necessary principle, audit trail (6-year retention), de-identification, BAAs.

**SOC2**: Trust service criteria (security, availability, processing integrity, confidentiality, privacy), change management (PR reviews, CI/CD gates), access control (unique accounts, MFA, quarterly reviews), monitoring and alerting.

**PCI-DSS**: CDE scope (never store CVV/PIN after auth), PAN encryption and masking, tokenization pattern, network segmentation, quarterly penetration testing.

**Cross-cutting**: Unified audit logging with required schema, append-only storage, fail-closed error handling.

See [references/assess-controls.md](references/assess-controls.md) for complete control checklists per framework with code patterns.

### Step 4: Identify Gaps

1. Collect all FAIL/WARN results from Step 3
2. Check code against **banned patterns**:

| Banned Pattern | Regulation | Alternative |
|---------------|------------|-------------|
| Storing CVV/PIN after auth | PCI-DSS | Tokenize via payment processor |
| Logging PHI identifiers | HIPAA | Log resource ID only |
| Pre-checked consent boxes | GDPR | Require explicit user action |
| Shared production accounts | SOC2 | Unique accounts with MFA |
| PII in URL query parameters | GDPR | Use POST body |
| Unencrypted PII in database | All | Column-level encryption |
| Indefinite data retention | All | Define retention + auto-purge |

3. Evaluate architectural fitness functions (classification coverage, encryption verification, audit completeness, retention enforcement, consent gates)
4. Assign severity: **Critical** (24h), **High** (72h), **Medium** (1 sprint), **Low** (backlog)

See [references/identify-gaps.md](references/identify-gaps.md) for detailed gap analysis procedures and fitness functions.

### Step 5: Generate Remediation Plan

For each gap, produce:
- Specific remediation action (imperative, not vague)
- Code pattern or configuration change required
- Files to modify
- Verification method

Order by severity (Critical first). Group related remediations.

See [references/generate-remediation-plan.md](references/generate-remediation-plan.md) for framework-specific remediation patterns with code examples.

### Step 6: Validate Compliance

1. Aggregate results per framework: **PASS** (all controls pass) / **CONDITIONAL PASS** (WARN items with accepted risks) / **FAIL** (unresolved gaps)
2. Produce compliance matrix using [templates/compliance-matrix.md](templates/compliance-matrix.md)
3. Log governance evaluations in audit trail format
4. Overall status: FAIL if ANY applicable framework is FAIL

See [references/validate-compliance.md](references/validate-compliance.md) for validation procedures and PR compliance checklist.

### Step 7: Produce Deliverables

Generate final outputs:
- Compliance matrix → [templates/compliance-matrix.md](templates/compliance-matrix.md)
- Data classification register → [templates/data-classification-register.md](templates/data-classification-register.md)

Validate against [checklists/definition-of-done.md](checklists/definition-of-done.md).

## Examples

### Example 1: SaaS Application (GDPR + SOC2)

```
Compliance Assessment: CONDITIONAL PASS

Applicable Frameworks:
  GDPR: PASS (all controls verified)
  SOC2: CONDITIONAL PASS (1 WARN: quarterly access review due next month)

Data Classification: 12 entities classified
  - 3 CONFIDENTIAL (user PII: email, name, address)
  - 2 INTERNAL (usage metrics)
  - 7 PUBLIC (marketing content)

Controls Assessed: 28
  PASS: 27 | WARN: 1 | FAIL: 0

Gaps: 0 critical, 0 high, 1 medium (access review scheduling)
```

### Example 2: Healthcare API (HIPAA + GDPR)

```
Compliance Assessment: FAIL

Applicable Frameworks:
  HIPAA: FAIL (2 critical gaps)
  GDPR: FAIL (1 high gap)

Critical Gaps:
  GAP-001 [HIPAA] Patient SSN logged in application logs
    → Remove PHI from log statements, log resource ID only. SLA: 24h
  GAP-002 [HIPAA] PHI returned in full record API responses
    → Create purpose-specific DTOs. SLA: 24h

High Gaps:
  GAP-003 [GDPR] No data export endpoint for data portability
    → Implement /api/v1/me/data-export. SLA: 72h
```

## Edge Cases

### Multi-Jurisdiction Application

Apply the strictest regulation. GDPR requirements typically supersede less strict local regulations. Document all applicable jurisdictions.

### Data Migration Projects

Apply the same compliance controls to the migration pipeline. Temporary data stores must meet encryption and access requirements.

### Third-Party Analytics

Client-side analytics must respect consent preferences. Defer script loading until consent is granted. Verify analytics vendor DPA is signed.

## Error Handling

### Cannot Determine Applicable Frameworks

Ask the user to identify data types processed. If PII is uncertain, assume GDPR applies (false positives are preferable to missed obligations).

### No Data Flow Diagrams Available

Proceed with code-level review. Trace data flows from API endpoints through services to data stores. Note in report that formal data flow diagrams were not available.

### Assessment Scope Too Large

Prioritize: (1) authentication/authorization code, (2) data access layer, (3) API endpoints handling sensitive data, (4) logging configuration. Document what was reviewed and what was deferred.

## Checklists

- **[definition-of-done.md](checklists/definition-of-done.md)**: Complete compliance assessment checklist covering all frameworks, data classification, cross-cutting controls, and deliverables

## Templates

- **[compliance-matrix.md](templates/compliance-matrix.md)**: Control-to-framework mapping with status, evidence, and gap references
- **[data-classification-register.md](templates/data-classification-register.md)**: Data entity classification with retention, encryption, and access requirements

## References

Detailed procedures for each step (load on demand):

- **[identify-applicable-frameworks.md](references/identify-applicable-frameworks.md)**: Framework applicability determination with data type triggers
- **[classify-data.md](references/classify-data.md)**: Data classification levels, entity enumeration, register production
- **[assess-controls.md](references/assess-controls.md)**: GDPR, HIPAA, SOC2, PCI-DSS control checklists with code patterns and audit logging schema
- **[identify-gaps.md](references/identify-gaps.md)**: Gap analysis, banned patterns, architectural fitness functions, severity assignment
- **[generate-remediation-plan.md](references/generate-remediation-plan.md)**: Framework-specific remediation patterns with code examples
- **[validate-compliance.md](references/validate-compliance.md)**: Final validation, compliance matrix production, PR checklist, audit trail
