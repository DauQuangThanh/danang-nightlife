# Definition of Done: IP Protection & Code Provenance

All criteria must pass for the IP protection assessment to be considered complete.

## Dependency Scanning

- [ ] All dependency manifests identified across all ecosystems
- [ ] Lockfiles present, committed to VCS, and hashes verified
- [ ] Full dependency tree extracted (direct + transitive)
- [ ] Every dependency has a recorded license SPDX identifier
- [ ] Dependency integrity verified (checksums match registry signatures)
- [ ] Newly added dependencies reviewed for typosquatting risks

## License Classification

- [ ] Every dependency classified as Approved, Conditional, Restricted, or Unknown
- [ ] No Restricted dependencies without written legal approval
- [ ] No Unknown dependencies without a resolution plan and timeline
- [ ] Conditional dependencies architecturally isolated with documented justification
- [ ] Dual-licensed dependencies have permissive license selected and documented
- [ ] License compatibility verified for the project's distribution model
- [ ] License matrix is complete and uses standard template

## Code Origin

- [ ] All code in the repository has a categorized and verified origin
- [ ] External code has documented source URL, license, and copyright notice
- [ ] THIRD_PARTY_NOTICES.md is complete with entries for all third-party code and dependencies
- [ ] Contractor code has signed IP assignment agreements on file
- [ ] Vendor SDK code has license agreements on file
- [ ] No code without clear provenance remains unresolved
- [ ] Forked dependencies retain original license and document modifications

## AI-Generated Code

- [ ] All AI-generated code identified in the repository
- [ ] AI-generated code marked with `// AI-GENERATED` comment
- [ ] AI-generated code reviewed by a human (PR review record exists)
- [ ] Similarity detection run against known open-source repositories
- [ ] No verbatim reproduction of restrictively-licensed code detected
- [ ] AI tool configurations enforce public code matching filters
- [ ] IP risk level documented for significant AI-generated blocks

## SBOM

- [ ] SBOM generated in CycloneDX or SPDX format
- [ ] SBOM contains all required fields (name, version, license, purl, hashes, relationships)
- [ ] SBOM includes both direct and transitive dependencies
- [ ] SBOM generation integrated into CI pipeline
- [ ] SBOM stored as a build artifact alongside the release
- [ ] SBOM components cross-referenced against license matrix
- [ ] SBOM is current (generated during the same CI run as the build)

## Clean-Room Development (if applicable)

- [ ] Clean-room implementations identified where required
- [ ] Functional specifications do not reference original source code
- [ ] Implementation teams signed declarations of no exposure to original code
- [ ] Independent code review performed by IP compliance team
- [ ] Plagiarism/similarity detection run against known sources
- [ ] Clean-room process documented with timestamps and participant records

## Supply Chain Security

- [ ] Lockfiles committed and verified
- [ ] Production dependencies pin exact versions (no ranges)
- [ ] Install-time code execution disabled where applicable
- [ ] Build provenance attestations generated (if applicable)
- [ ] Registry allowlists configured (if enterprise environment)

## Banned Patterns

- [ ] No GPL/AGPL dependency in proprietary project
- [ ] No copy-paste from GPL-licensed repository
- [ ] No unlicensed dependencies
- [ ] No vendor SDK without license agreement
- [ ] No AI-generated code without review marker
- [ ] No dependency version ranges in production
- [ ] No internal code published without IP review

## Deliverables

- [ ] License matrix produced and complete
- [ ] SBOM generated and validated
- [ ] Code origin report produced and complete
- [ ] Gap analysis documented with severity and SLAs
- [ ] Remediation plan produced for all FAIL gaps
- [ ] Governance audit trail entries logged for all evaluations
- [ ] Overall IP compliance status determined (PASS/CONDITIONAL PASS/FAIL)
