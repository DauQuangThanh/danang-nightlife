# Code Origin Report

**Project**: [PROJECT NAME]
**Date**: [YYYY-MM-DD]
**Assessor**: [AGENT ID / REVIEWER NAME]
**Commit SHA**: [COMMIT SHA]
**Overall Status**: [PASS / CONDITIONAL PASS / FAIL]

---

## Origin Summary

| Origin Type               | File Count | Percentage | Status    |
| ------------------------- | ---------- | ---------- | --------- |
| Internal development      | [n]        | [%]        | [Verified]|
| Open-source copy          | [n]        | [%]        | [Verified/Gaps] |
| AI-generated code         | [n]        | [%]        | [Verified/Gaps] |
| External contractor       | [n]        | [%]        | [Verified/Gaps] |
| Stack Overflow / blog     | [n]        | [%]        | [Verified/Gaps] |
| Vendor SDK / proprietary  | [n]        | [%]        | [Verified/Gaps] |
| Unknown origin            | [n]        | [%]        | [Action Required] |

---

## Internal Development

All files authored by internal team members via authenticated git commits. No additional documentation required.

| Directory / Module  | Primary Authors           | Verified |
| ------------------- | ------------------------- | -------- |
| [src/module]        | [author1, author2]        | [YES]    |

---

## Open-Source Code

| File / Directory    | Source URL                           | License (SPDX) | Copyright              | In THIRD_PARTY_NOTICES | Compatible |
| ------------------- | ------------------------------------ | --------------- | ---------------------- | ---------------------- | ---------- |
| [path/to/file]      | [https://github.com/...]             | [MIT]           | [(c) YYYY Author]      | [YES/NO]               | [YES/NO]   |

---

## AI-Generated Code

| File / Code Block   | AI Tool          | Marker Present | Human Reviewed | Similarity Check | IP Risk Level | Notes |
| ------------------- | ---------------- | -------------- | -------------- | ---------------- | ------------- | ----- |
| [path/to/file:L1-50]| [Copilot/Claude] | [YES/NO]       | [YES/NO]       | [PASS/FAIL]      | [Low/Med/High]| -     |

### AI Tool Configuration

| Tool            | Public Code Filter | Setting                        | Verified |
| --------------- | ------------------ | ------------------------------ | -------- |
| GitHub Copilot  | [Enabled/Disabled] | Block suggestions matching public code | [YES/NO] |
| [Other tool]    | [Enabled/Disabled] | [Setting description]          | [YES/NO] |

---

## External Contractor Code

| File / Directory    | Contractor           | IP Assignment Agreement | Agreement Reference | Verified |
| ------------------- | -------------------- | ----------------------- | ------------------- | -------- |
| [path/to/file]      | [Contractor name]    | [YES/NO]                | [Agreement ID/path] | [YES/NO] |

---

## Vendor SDK / Proprietary Code

| File / Directory    | Vendor          | License Agreement | Agreement Reference | Usage Compliant | Notes |
| ------------------- | --------------- | ----------------- | ------------------- | --------------- | ----- |
| [path/to/file]      | [Vendor name]   | [YES/NO]          | [Agreement ID/path] | [YES/NO]        | -     |

---

## Stack Overflow / Blog Code

| File / Code Block   | Source URL                        | Source License   | Compatible | Attributed |
| ------------------- | --------------------------------- | ---------------- | ---------- | ---------- |
| [path/to/file:L1-20]| [https://stackoverflow.com/...]   | [CC BY-SA 4.0]   | [YES/NO]   | [YES/NO]   |

---

## Clean-Room Implementations

| Component           | Reason for Clean-Room              | Spec Reviewed by Legal | Team Isolated | Similarity Check | Process Documented |
| ------------------- | ---------------------------------- | ---------------------- | ------------- | ---------------- | ------------------ |
| [component name]    | [Replacing GPL component / etc]    | [YES/NO]               | [YES/NO]      | [PASS/FAIL]      | [YES/NO]           |

---

## Unknown Origin (Action Required)

| File / Code Block   | Suspected Origin     | Risk Assessment        | Resolution Plan              | SLA     |
| ------------------- | -------------------- | ---------------------- | ---------------------------- | ------- |
| [path/to/file]      | [Possible copy-paste]| [License risk unknown] | [Investigate / Rewrite]      | [1 wk]  |

---

## Gaps and Remediation

| Gap ID  | Category              | Description                              | Severity | SLA    | Status      |
| ------- | --------------------- | ---------------------------------------- | -------- | ------ | ----------- |
| ORI-001 | [Attribution]         | [Missing THIRD_PARTY_NOTICES entry]      | [Med]    | [1 wk] | [Open/Closed]|
| ORI-002 | [AI marking]          | [Unmarked AI-generated code]             | [High]   | [48h]  | [Open/Closed]|

---

## Governance Audit Trail

```yaml
# Origin verification results
- rule: <rule-name>
  result: PASS | FAIL | WARN
  files: ["<affected-files>"]
  detail: "<description of finding>"
  remediation: "<remediation hint>"
```
