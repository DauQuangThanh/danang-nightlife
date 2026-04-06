# Software Bill of Materials (SBOM)

**Project**: [PROJECT NAME]
**Date**: [YYYY-MM-DD]
**Build ID**: [CI BUILD ID]
**Commit SHA**: [COMMIT SHA]
**Format**: [CycloneDX JSON / SPDX JSON]
**Spec Version**: [CycloneDX 1.5 / SPDX 2.3]

---

## Generation Details

| Attribute          | Value                                |
| ------------------ | ------------------------------------ |
| Tool               | [cyclonedx-python / syft / trivy]    |
| Generated At       | [ISO 8601 timestamp]                 |
| CI Pipeline        | [GitHub Actions / GitLab CI / etc]   |
| Artifact Location  | [S3 path / artifact registry URL]    |
| Signed             | [YES (Sigstore/GPG) / NO]           |

---

## Component Summary

| Metric                    | Count |
| ------------------------- | ----- |
| Total components          | [N]   |
| Direct dependencies       | [n]   |
| Transitive dependencies   | [n]   |
| Components with license   | [n]   |
| Components without license| [n]   |
| Known vulnerabilities     | [n]   |

---

## Components

| Component Name | Version | SPDX License | Package URL (purl)                | SHA-256 Hash      | Dependency Type | Supplier       |
| -------------- | ------- | ------------ | --------------------------------- | ----------------- | --------------- | -------------- |
| [name]         | [x.y.z] | [MIT]        | [pkg:npm/name@version]            | [hash]            | [direct/transitive] | [author/org] |

---

## Dependency Relationships

| Component          | Depends On          | Relationship Type |
| ------------------ | ------------------- | ----------------- |
| [parent-component] | [child-component]   | [depends-on]      |

---

## Known Vulnerabilities (VEX)

| Component    | Version | CVE ID         | Severity | Status               | Justification                    |
| ------------ | ------- | -------------- | -------- | -------------------- | -------------------------------- |
| [name]       | [x.y.z] | [CVE-YYYY-NNNNN] | [Critical/High/Medium/Low] | [affected/not_affected/fixed] | [Explanation if not_affected] |

---

## SBOM Lifecycle Status

- [ ] Generated during CI build (not manually)
- [ ] Stored as build artifact alongside the release
- [ ] Published to internal registry for dependency tracking
- [ ] Upstream vendor SBOMs consumed for supply chain visibility
- [ ] Monitored against vulnerability databases continuously
- [ ] Regenerated on last dependency update

---

## SBOM File Reference

The machine-readable SBOM file is located at:
- **CycloneDX JSON**: `[path/to/sbom.cdx.json]`
- **SPDX JSON**: `[path/to/sbom.spdx.json]`

This human-readable document supplements the machine-readable SBOM for review purposes.
