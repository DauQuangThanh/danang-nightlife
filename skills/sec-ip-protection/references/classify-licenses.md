# Step 2: Classify Licenses

## RULES

- Every dependency license MUST be classified into exactly one category: Approved, Conditional, Restricted, or Unknown.
- Restricted licenses BLOCK the build for proprietary projects. No exceptions without written legal approval.
- Unknown licenses BLOCK the build. No exceptions.
- Conditional licenses require architectural isolation and justification.
- Dual-licensed dependencies: select and document the permissive license.
- If a dependency changed its license in a new version, the old version remains under the old license. Pin to the last permissively-licensed version until a migration plan is in place.

## INSTRUCTIONS

1. Classify each dependency's license according to the organization's license policy:

   | Category    | Licenses                                          | Policy                                          |
   | ----------- | ------------------------------------------------- | ----------------------------------------------- |
   | Approved    | MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, Unlicense, CC0-1.0 | Use freely. Include license notice in attribution file. |
   | Conditional | MPL-2.0, LGPL-2.1, LGPL-3.0, EPL-2.0, CDDL-1.0 | Permitted with restrictions. Must isolate as a separate module/library. No modification without legal review. |
   | Restricted  | GPL-2.0, GPL-3.0, AGPL-3.0, SSPL, BSL, Elastic-2.0 | BANNED for proprietary projects. Requires legal approval and architectural isolation. AGPL is banned for SaaS. |
   | Unknown     | No license file, custom license, unclear terms    | BANNED until license is clarified. Contact maintainer or legal team. |

2. For dual-licensed dependencies (e.g., "MIT OR GPL-3.0"):
   - Select the permissive license option
   - Document the selected license in the license matrix
   - Ensure the selected license is reflected in THIRD_PARTY_NOTICES

3. For dependencies where the LICENSE file and package metadata disagree:
   - Trust the LICENSE file in the repository root
   - Report the discrepancy to the package maintainer
   - Document the discrepancy in the license matrix

4. Evaluate license compatibility when combining libraries in a single distribution:

   | Project License | Can Use MIT | Can Use Apache-2.0 | Can Use LGPL-2.1 | Can Use GPL-3.0 | Can Use AGPL-3.0 |
   | --------------- | ----------- | ------------------- | ----------------- | ---------------- | ----------------- |
   | Proprietary     | Yes         | Yes                 | Dynamic link only | NO               | NO                |
   | MIT             | Yes         | Yes                 | Dynamic link only | NO (unless relicense) | NO           |
   | Apache-2.0      | Yes         | Yes                 | Dynamic link only | NO               | NO                |
   | GPL-3.0         | Yes         | Yes                 | Yes               | Yes              | NO                |
   | AGPL-3.0        | Yes         | Yes                 | Yes               | Yes              | Yes               |

5. For Conditional-licensed dependencies:
   - Verify they are architecturally isolated (separate module/library, dynamic linking only)
   - Document the justification for their use
   - Confirm no modifications have been made without legal review

6. For each Restricted or Unknown dependency, document:
   - Package name and version
   - License identified (or "Unknown")
   - Impact assessment (what functionality depends on this package)
   - Candidate replacement (Approved-licensed alternative)
   - Removal SLA (48h for GPL-contaminated, 1 week for other violations)

7. Produce the license matrix using the template at [../templates/license-matrix.md](../templates/license-matrix.md).

8. Apply the CI policy rules:
   - BLOCK merge if any dependency has a Restricted license
   - BLOCK merge if any dependency has an Unknown license
   - BLOCK merge if any dependency lacks a license file
   - WARN if any dependency has a Conditional license (require justification comment)
   - WARN if a new dependency is added (require explicit acknowledgment)

## VALIDATION

- [ ] Every dependency is classified as Approved, Conditional, Restricted, or Unknown
- [ ] No Restricted dependencies remain without documented legal approval
- [ ] No Unknown dependencies remain without a resolution plan
- [ ] Conditional dependencies are architecturally isolated with documented justification
- [ ] Dual-licensed dependencies have the permissive license selected and documented
- [ ] License compatibility verified for the project's distribution model
- [ ] License matrix is complete using the standard template
- [ ] CI policy rules documented (block/warn thresholds)

