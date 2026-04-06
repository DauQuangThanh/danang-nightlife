---
name: sec-ip-protection
description: "Performs code origin verification, license scanning, clean-room development enforcement, and IP contamination prevention. Generates license matrices, SBOMs, and origin reports. Use when reviewing code provenance, checking license compatibility, auditing dependencies, or when user mentions IP protection, license compliance, clean-room, code origin, SBOM, or open-source risk."
license: MIT
metadata:
  author: Dau Quang Thanh
  version: "3.0.0"
  last_updated: "2026-02-08"
  category: security
  tags: "ip-protection, license, clean-room, code-origin, open-source, compliance, provenance, sbom"
---

# IP Protection & Code Provenance

## Overview

This skill performs intellectual property protection assessments for codebases. It scans dependencies for license compliance, verifies code origin and provenance, checks AI-generated code for IP risks, generates Software Bills of Materials (SBOMs), and validates clean-room development practices. The output is a complete IP compliance assessment with actionable remediation.

## When to Use

- Reviewing code provenance before release or deployment
- Scanning dependencies for license compatibility (OWASP, OpenChain ISO 5230)
- Auditing AI-generated code for IP contamination risks
- Generating or validating SBOMs (CycloneDX/SPDX)
- Enforcing clean-room development when replacing copyleft components
- When user mentions "IP protection", "license compliance", "code origin", "SBOM", or "open-source risk"

## Prerequisites

- Access to source code repository and dependency manifests
- License scanning tool configured (FOSSA, Snyk, Trivy, or ScanCode)
- Understanding of the project's distribution model (SaaS, on-premises, embedded, open-source)

## Governance Rules

1. All open-source licenses MUST be classified as **Approved**, **Conditional**, **Restricted**, or **Unknown**
2. **Restricted** licenses (GPL, AGPL, SSPL) are BANNED for proprietary projects — no exceptions without legal approval
3. **Unknown** licenses (missing LICENSE file, custom terms) are BANNED until clarified
4. All code MUST have verifiable origin
5. AI-generated code MUST be marked with `// AI-GENERATED` and reviewed
6. Every release MUST include an SBOM in CycloneDX or SPDX format
7. Every project MUST maintain `THIRD_PARTY_NOTICES.md`
8. Lockfiles MUST be committed; production dependencies MUST pin exact versions
9. GPL-contaminated code: **48h removal SLA**. License violation: **1 week SLA**

## Instructions

### Step 1: Scan Dependencies

Extract the full dependency tree including all transitive dependencies.

1. Identify ecosystems and locate dependency manifests (`package.json`, `requirements.txt`, `pom.xml`, `go.mod`, `*.csproj`, `Cargo.toml`)
2. Validate lockfiles are present and committed to VCS
3. Extract full tree using scanning tools (FOSSA/Snyk/Trivy or ecosystem-specific tools)
4. Record for each dependency: name, exact version, SPDX license, direct/transitive, purl, source URL, SHA-256 hash
5. Flag dependencies without identifiable licenses as Unknown
6. Verify integrity: checksums match registry signatures, lockfile hashes match resolved tree
7. Check newly added dependencies for typosquatting risks

See [references/scan-dependencies.md](references/scan-dependencies.md) for ecosystem-specific tool configurations and detailed scanning procedures.

### Step 2: Classify Licenses

Classify every dependency into exactly one category:

| Category | Licenses | Policy |
|----------|----------|--------|
| **Approved** | MIT, Apache-2.0, BSD-2/3-Clause, ISC, Unlicense, CC0-1.0 | Use freely. Include in attribution file. |
| **Conditional** | MPL-2.0, LGPL-2.1/3.0, EPL-2.0, CDDL-1.0 | Must isolate as separate module. No modification without legal review. |
| **Restricted** | GPL-2.0/3.0, AGPL-3.0, SSPL, BSL, Elastic-2.0 | BANNED for proprietary. Requires legal approval. AGPL banned for SaaS. |
| **Unknown** | No license, custom, unclear terms | BANNED until clarified. |

- Dual-licensed: select and document the permissive option
- CI policy: BLOCK on Restricted/Unknown, WARN on Conditional
- Produce license matrix using [templates/license-matrix.md](templates/license-matrix.md)

See [references/classify-licenses.md](references/classify-licenses.md) for compatibility matrices and detailed classification procedures.

### Step 3: Verify Code Origin

Categorize all code by origin and verify provenance:

| Origin | Verification | Documentation |
|--------|-------------|---------------|
| Internal development | Git history with authenticated author | Standard commits |
| Open-source copy | Source URL, license, copyright notice | THIRD_PARTY_NOTICES entry |
| AI-generated | `// AI-GENERATED` marker + review | Reviewed for IP |
| External contractor | Signed IP assignment agreement | Agreement reference |
| Stack Overflow/blog | Source URL + license (CC BY-SA 4.0) | License compatibility check |
| Vendor SDK | License agreement on file | Agreement reference |

Verify `THIRD_PARTY_NOTICES.md` is complete with entries for all third-party code.

See [references/verify-code-origin.md](references/verify-code-origin.md) for detailed verification procedures and THIRD_PARTY_NOTICES format.

### Step 4: Check AI-Generated Code

1. Search for `// AI-GENERATED` markers and AI tool references in commits/PRs
2. Verify each block: marked, human-reviewed, similarity-checked against open-source
3. Run similarity detection against popular repositories in the same language
4. Assess IP risk: Low (boilerplate/tests) → Medium (utilities) → High (core business logic)
5. Verify AI tool configs enforce public code matching filters (e.g., Copilot block setting)

See [references/check-ai-generated-code.md](references/check-ai-generated-code.md) for detailed AI code assessment procedures.

### Step 5: Generate SBOM

Generate or validate SBOM in CycloneDX or SPDX format:

1. Use ecosystem-appropriate tool (`cyclonedx-python`, `cyclonedx-npm`, `syft`, etc.)
2. Verify required fields: component name/version, SPDX license, purl, SHA-256, dependency graph
3. Integrate into CI pipeline (not manual generation)
4. Cross-reference against license matrix — flag unclassified components
5. Store as build artifact alongside the release

See [references/generate-sbom.md](references/generate-sbom.md) for ecosystem-specific tools and CI pipeline examples.

### Step 6: Validate Clean-Room & Final Assessment

1. **Clean-room validation** (if applicable): Verify 3-phase process (specification → isolated implementation → verification) for any reimplemented functionality
2. **Supply chain security**: Lockfiles committed, exact versions pinned, install-time scripts disabled
3. **Banned patterns check**: No GPL in proprietary, no unlicensed deps, no unmarked AI code, no version ranges in production
4. **Final verdict**: PASS / CONDITIONAL PASS / FAIL
5. **Audit trail**: Log all evaluations with timestamp, rule, result, affected files, remediation

See [references/validate-clean-room.md](references/validate-clean-room.md) for complete clean-room procedures and banned patterns list.

### Step 7: Produce Deliverables

Generate final outputs using templates:

- License matrix → [templates/license-matrix.md](templates/license-matrix.md)
- SBOM documentation → [templates/sbom-template.md](templates/sbom-template.md)
- Code origin report → [templates/origin-report.md](templates/origin-report.md)

Validate against [checklists/definition-of-done.md](checklists/definition-of-done.md).

## Examples

### Example 1: Clean Project (PASS)

```
IP Compliance Assessment: PASS
- Dependencies: 47 total (45 Approved, 2 Conditional with isolation documented)
- Code origin: 100% verified (internal + 3 MIT libraries attributed)
- AI code: 12 blocks marked, reviewed, no similarity matches
- SBOM: CycloneDX generated in CI, all components classified
- Clean-room: N/A
```

### Example 2: Violations Found (FAIL)

```
IP Compliance Assessment: FAIL
- CRITICAL: `image-processor@2.1.0` has GPL-3.0 license (Restricted)
  → Replace with `sharp@0.33.0` (Apache-2.0) within 48h
- CRITICAL: `utils/parser.js` copied from GPL repo without attribution
  → Rewrite from specification, remove copied code
- HIGH: 3 AI-generated files missing // AI-GENERATED markers
  → Add markers and complete review
- MEDIUM: SBOM missing 2 transitive dependencies
  → Regenerate SBOM from lockfile
```

## Edge Cases

### License Changed in Upstream Version

Pin to the last permissively-licensed version. Document migration plan. Monitor for alternative packages.

### Transitive Dependency with Restricted License

Replace the direct dependency that pulls in the restricted transitive. Do not attempt to isolate transitives.

### Internal Libraries Shared Between Teams

Treat as implicit proprietary license. Establish clear ownership and contribution guidelines.

## Error Handling

### License Scanner Cannot Identify License

Flag as Unknown, block PR. Manually inspect the package's repository for LICENSE file. Contact maintainer if absent.

### Conflicting License Information

Trust the LICENSE file in the repository root over package metadata. Report discrepancy to maintainer. Document in license matrix.

### SBOM Generation Fails

Do NOT skip. Diagnose tool configuration. Missing SBOMs break supply chain compliance requirements.

## Checklists

- **[definition-of-done.md](checklists/definition-of-done.md)**: Complete IP protection assessment checklist covering all 6 steps, supply chain security, banned patterns, and deliverables

## Templates

- **[license-matrix.md](templates/license-matrix.md)**: Dependency license classification matrix
- **[sbom-template.md](templates/sbom-template.md)**: SBOM documentation template
- **[origin-report.md](templates/origin-report.md)**: Code origin verification report

## References

Detailed procedures for each step (load on demand):

- **[scan-dependencies.md](references/scan-dependencies.md)**: Ecosystem-specific scanning tools, lockfile validation, integrity checks
- **[classify-licenses.md](references/classify-licenses.md)**: License categories, compatibility matrices, CI policy rules
- **[verify-code-origin.md](references/verify-code-origin.md)**: Origin categorization, THIRD_PARTY_NOTICES format, contractor/vendor verification
- **[check-ai-generated-code.md](references/check-ai-generated-code.md)**: AI code identification, similarity detection, risk assessment
- **[generate-sbom.md](references/generate-sbom.md)**: SBOM tools by ecosystem, CI integration examples, validation
- **[validate-clean-room.md](references/validate-clean-room.md)**: Clean-room 3-phase process, supply chain controls, banned patterns, final assessment
