# Step 6: Validate Clean-Room

## RULES

- Clean-room development MUST be followed when reimplementing functionality from a competitor, replacing copyleft components, or building alternatives to incompatibly-licensed libraries.
- The implementation team MUST NOT have viewed the original source code.
- Supply chain security controls are non-negotiable: lockfiles, pinned versions, signed artifacts.
- The overall IP assessment is FAIL if ANY Restricted or Unknown dependency remains unresolved, or if ANY code lacks verifiable provenance.

## INSTRUCTIONS

### 6A. Clean-Room Development Validation

1. Identify any code that required clean-room practices:
   - Reimplementation of competitor product functionality
   - Replacement of GPL/AGPL-licensed components with proprietary ones
   - Alternatives to libraries with incompatible licensing
   - Ported features from codebases with unclear IP ownership

2. For each clean-room implementation, verify the three-phase process:

   **Phase 1: Specification (Legal-Approved)**
   - [ ] Functional specification documents WHAT the component does
   - [ ] Specification does NOT reference the original source code
   - [ ] Only publicly documented APIs, standards (RFCs), and documentation were used
   - [ ] Legal reviewed the specification for IP contamination risk

   **Phase 2: Implementation (Isolated Team)**
   - [ ] Implementation team has NOT viewed the original source code
   - [ ] Signed declarations confirming no exposure to original implementation
   - [ ] Work was done from the functional specification only
   - [ ] Only approved reference materials used (RFCs, official docs, textbooks)

   **Phase 3: Verification**
   - [ ] Output behavior compared against specification (not code comparison)
   - [ ] Independent code review by IP compliance team
   - [ ] Automated plagiarism/similarity detection run against known sources
   - [ ] Clean-room process documented with timestamps and participant records

### 6B. Supply Chain Security Validation

1. Verify dependency integrity controls:
   - [ ] Package checksums verified against registry signatures
   - [ ] Lockfiles committed to VCS
   - [ ] Production dependencies pin exact versions (no ranges like `^1.0.0`)
   - [ ] Install-time code execution disabled (`npm --ignore-scripts` or equivalent)
   - [ ] Private registry mirrors used for critical dependencies (if applicable)

2. Verify typosquatting prevention:
   - [ ] Package names reviewed for similarity to popular packages
   - [ ] Download counts, repository activity, and maintainer history checked
   - [ ] Organization-scoped packages used where available
   - [ ] Registry allowlists configured in enterprise environments (if applicable)

3. Verify build provenance:
   - [ ] Release artifacts signed with Sigstore or GPG (if applicable)
   - [ ] SLSA provenance attestations generated for build outputs (if applicable)
   - [ ] Build logs and environment details stored for forensic analysis
   - [ ] Reproducible builds verified from source (if applicable)

### 6C. Final IP Compliance Assessment

1. Aggregate results from all previous steps and check against the banned patterns list:

   | Pattern                                     | Reason                                 | Alternative                                 |
   | ------------------------------------------- | -------------------------------------- | ------------------------------------------- |
   | GPL/AGPL dependency in proprietary project  | Copyleft contamination                 | Find MIT/Apache-licensed alternative        |
   | Copy-paste from GPL-licensed repository     | License violation                      | Rewrite from specification, cite no source  |
   | Unlicensed dependency (no LICENSE file)     | Unknown legal obligation               | Contact maintainer or find alternative      |
   | Vendor SDK without license agreement        | Unclear usage rights                   | Obtain and file license agreement first     |
   | AI-generated code without review marker     | IP provenance unknown                  | Add `// AI-GENERATED` and review            |
   | Dependency version ranges in production     | Supply chain attack vector             | Pin exact versions, use lockfile            |
   | Internal code published without IP review   | Accidental IP disclosure               | IP review required before any publication   |

2. Evaluate architectural fitness functions:
   - **License Compliance**: All dependencies have approved SPDX license identifiers. Restricted or Unknown licenses block the build.
   - **Attribution Completeness**: Every third-party dependency has a corresponding entry in THIRD_PARTY_NOTICES.md.
   - **SBOM Freshness**: SBOM generated within the same CI run as the release build.
   - **Lockfile Integrity**: Lockfile hash matches the resolved dependency tree.
   - **AI Code Marking**: Files modified by AI assistance contain `AI-GENERATED` markers.

3. Run the IP protection checklist for the PR:
   - [ ] No new dependencies with Restricted licenses (GPL, AGPL, SSPL)
   - [ ] All new dependencies have identifiable licenses (no Unknown)
   - [ ] Conditional-licensed dependencies are architecturally isolated
   - [ ] THIRD_PARTY_NOTICES.md updated for any new external code
   - [ ] AI-generated code marked with `// AI-GENERATED` comment
   - [ ] No verbatim code copied from Stack Overflow or blogs without attribution
   - [ ] Clean-room process documented if reimplementing existing functionality
   - [ ] SBOM regenerated if dependencies changed
   - [ ] No proprietary third-party code committed without license agreement on file

4. Determine overall IP compliance status:
   - **PASS**: All dependencies approved, all code has verified provenance, no banned patterns.
   - **CONDITIONAL PASS**: All blocking issues resolved, minor WARN items remain with justification.
   - **FAIL**: Restricted/Unknown dependencies, unverified code origin, or banned pattern detected.

5. Log all governance evaluations in the audit trail format:
   ```yaml
   - rule: license-compliance
     result: PASS | FAIL | WARN
     files: ["<affected-files>"]
     detail: "<description of finding>"
     remediation: "<remediation hint>"

   - rule: attribution-completeness
     result: PASS | FAIL | WARN
     files: ["THIRD_PARTY_NOTICES.md"]
     detail: "<description of finding>"
     remediation: "<remediation hint>"
   ```

6. For edge cases encountered:
   - **License change in upstream**: pin to last permissively-licensed version; document migration plan
   - **Transitive dependency with restricted license**: evaluate entire dependency chain; replace the direct dependency that pulls in the restricted transitive
   - **Internal libraries between teams**: establish clear ownership and contribution guidelines

7. For error conditions:
   - **License scanner unable to identify license**: flag as Unknown, block PR, manually inspect
   - **Conflicting license information**: trust the LICENSE file in the repository root; report discrepancy
   - **New dependency added without review**: CI auto-detects new lockfile entries, requires explicit approval

## VALIDATION

- [ ] Clean-room development practices verified where applicable
- [ ] Supply chain security controls verified
- [ ] Banned patterns list checked against codebase
- [ ] Architectural fitness functions evaluated
- [ ] PR IP protection checklist completed
- [ ] Overall IP compliance status determined
- [ ] Governance audit trail entries logged

