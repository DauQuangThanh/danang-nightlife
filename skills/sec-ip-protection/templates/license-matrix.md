# License Matrix

**Project**: [PROJECT NAME]
**Date**: [YYYY-MM-DD]
**Assessor**: [AGENT ID / REVIEWER NAME]
**Commit SHA**: [COMMIT SHA]
**Distribution Model**: [SaaS / On-Premises / Embedded / Open-Source]
**Project License**: [LICENSE SPDX ID]
**Overall Status**: [PASS / CONDITIONAL PASS / FAIL]

---

## Classification Policy

| Category    | Licenses                                          | Policy                                          |
| ----------- | ------------------------------------------------- | ----------------------------------------------- |
| Approved    | MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, Unlicense, CC0-1.0 | Use freely. Include license notice in attribution file. |
| Conditional | MPL-2.0, LGPL-2.1, LGPL-3.0, EPL-2.0, CDDL-1.0 | Permitted with restrictions. Must isolate. No modification without legal review. |
| Restricted  | GPL-2.0, GPL-3.0, AGPL-3.0, SSPL, BSL, Elastic-2.0 | BANNED for proprietary projects. Requires legal approval. |
| Unknown     | No license file, custom license, unclear terms    | BANNED until license is clarified. |

---

## Direct Dependencies

| Package Name | Version | License (SPDX) | Category    | Source Repository                    | Compliant | Notes |
| ------------ | ------- | --------------- | ----------- | ------------------------------------ | --------- | ----- |
| [name]       | [x.y.z] | [MIT]           | [Approved]  | [https://github.com/...]             | [YES/NO]  | -     |

---

## Transitive Dependencies

| Package Name | Version | License (SPDX) | Category    | Pulled By (Direct Dep) | Compliant | Notes |
| ------------ | ------- | --------------- | ----------- | ----------------------- | --------- | ----- |
| [name]       | [x.y.z] | [MIT]           | [Approved]  | [parent-package]        | [YES/NO]  | -     |

---

## Conditional Dependencies (Requires Justification)

| Package Name | Version | License (SPDX) | Justification           | Isolation Method       | Legal Review | Status    |
| ------------ | ------- | --------------- | ----------------------- | ---------------------- | ------------ | --------- |
| [name]       | [x.y.z] | [LGPL-3.0]     | [Why this dep is needed]| [Dynamic linking only] | [YES/NO]     | [Approved/Pending] |

---

## Restricted Dependencies (Action Required)

| Package Name | Version | License (SPDX) | Impact Assessment                    | Candidate Replacement         | Removal SLA | Status    |
| ------------ | ------- | --------------- | ------------------------------------ | ----------------------------- | ----------- | --------- |
| [name]       | [x.y.z] | [GPL-3.0]      | [What functionality depends on this] | [Alternative package (MIT)]   | [48h/1wk]   | [Open/Resolved] |

---

## Unknown Dependencies (Action Required)

| Package Name | Version | License Info Available | Investigation Status | Resolution Plan                | SLA    |
| ------------ | ------- | ---------------------- | -------------------- | ------------------------------ | ------ |
| [name]       | [x.y.z] | [None / Custom text]   | [Investigating/Blocked] | [Contact maintainer / Replace] | [1 wk] |

---

## Dual-Licensed Dependencies

| Package Name | Version | Available Licenses       | Selected License | Documented In          |
| ------------ | ------- | ------------------------ | ---------------- | ---------------------- |
| [name]       | [x.y.z] | [MIT OR GPL-3.0]         | [MIT]            | [THIRD_PARTY_NOTICES]  |

---

## License Compatibility Matrix (for this project)

| Project License: [LICENSE] | Can Use MIT | Can Use Apache-2.0 | Can Use LGPL | Can Use GPL | Can Use AGPL |
| -------------------------- | ----------- | ------------------- | ------------ | ----------- | ------------ |
| Compatibility              | [Yes/No]    | [Yes/No]            | [Yes/No]     | [Yes/No]    | [Yes/No]     |

---

## Summary

| Category    | Count | Compliant | Non-Compliant | Action Required |
| ----------- | ----- | --------- | ------------- | --------------- |
| Approved    | [n]   | [n]       | [0]           | None            |
| Conditional | [n]   | [n]       | [n]           | [Justification/Isolation] |
| Restricted  | [n]   | [0]       | [n]           | [Remove/Replace within SLA] |
| Unknown     | [n]   | [0]       | [n]           | [Investigate/Replace within SLA] |
| **Total**   | [N]   | [n]       | [n]           | -               |

---

## CI Policy Configuration

```
BLOCK on: Restricted license, Unknown license, missing LICENSE file
WARN on: Conditional license (require justification), new dependency added
Tool: [FOSSA / Snyk / Trivy / liccheck]
Config file: [path to policy config]
```
