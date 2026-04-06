# Step 3: Verify Code Origin

## RULES

- ALL code in the repository MUST have a verifiable origin.
- Code copied from external sources MUST include the source URL, license, and original copyright notice.
- Every project MUST maintain a THIRD_PARTY_NOTICES.md attribution file.
- Forking an open-source project does NOT change its license. The fork remains under the original license terms.
- Internal libraries shared between teams are treated as having an implicit proprietary license.

## INSTRUCTIONS

1. Categorize all code in the repository by origin type:

   | Origin Type               | Verification Method                                | Documentation Required              |
   | ------------------------- | -------------------------------------------------- | ----------------------------------- |
   | Internal development      | Git commit history with authenticated author       | None beyond standard commits        |
   | Open-source copy          | Source URL, license, and original copyright notice  | Attribution in THIRD_PARTY_NOTICES  |
   | AI-generated code         | Flagged with `// AI-GENERATED` comment and review  | Reviewed for IP and correctness     |
   | External contractor       | Signed IP assignment agreement on file              | Contractor agreement reference      |
   | Stack Overflow / blog     | Source URL and license (CC BY-SA 4.0 for SO)       | Check license compatibility         |
   | Vendor SDK / proprietary  | License agreement on file                          | Agreement reference in DEPENDENCIES |

2. For code identified as copied from external sources:
   - Verify the source URL is documented (in comments or THIRD_PARTY_NOTICES)
   - Verify the license of the original source is compatible with the project
   - Verify the original copyright notice is preserved
   - Check Stack Overflow code for CC BY-SA 4.0 compatibility (copyleft-like for modifications)

3. For code from external contractors:
   - Verify a signed IP assignment agreement is on file
   - Verify the contractor agreement reference is documented
   - Check that the contractor did not introduce code from their other clients

4. For vendor SDKs and proprietary code:
   - Verify a license agreement is on file
   - Verify usage complies with license terms (seat limits, distribution restrictions, etc.)
   - Document the agreement reference

5. Verify the THIRD_PARTY_NOTICES.md file is complete and up to date:
   - Every third-party dependency and code snippet must have a corresponding entry
   - Each entry must include: library name, version, license, copyright, source URL, usage description
   - Modified third-party code must note the modifications

   Required format:
   ```
   ## Third-Party Software Notices

   ### library-name (version)
   - License: MIT
   - Copyright: (c) 2024 Author Name
   - Source: https://github.com/author/library-name
   - Usage: Used for HTTP request handling

   ### another-library (version)
   - License: Apache-2.0
   - Copyright: (c) 2024 Organization
   - Source: https://github.com/org/another-library
   - Modifications: Patched CVE-2024-XXXX (see patches/another-library.patch)
   ```

6. Check for code without clear origin:
   - Files without git history (added in bulk without context)
   - Code blocks that appear to be copied but lack attribution
   - Utility functions that match common open-source patterns

7. For forked dependencies:
   - Verify the fork retains the original license
   - Verify modifications comply with the original license terms
   - Document the fork in THIRD_PARTY_NOTICES with modification notes

## VALIDATION

- [ ] All code in the repository has a categorized origin
- [ ] External code has documented source URL, license, and copyright
- [ ] THIRD_PARTY_NOTICES.md is complete with entries for all third-party code
- [ ] Contractor code has IP assignment agreements on file
- [ ] Vendor SDK code has license agreements on file
- [ ] No code without clear origin remains unresolved
- [ ] Forked dependencies retain original license and document modifications

