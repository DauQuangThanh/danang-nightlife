# Step 1: Scan Dependencies

## RULES

- The full dependency tree MUST be extracted, including all transitive dependencies.
- Every dependency MUST have its license identified. Dependencies without identifiable licenses are flagged as Unknown.
- Scanning MUST use lockfiles (not just manifests) to capture exact resolved versions.
- Scanning MUST run on every PR, every new dependency addition, and quarterly as a full audit.

## INSTRUCTIONS

1. Identify the project's ecosystem(s) and locate all dependency manifests:
   - Python: `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`
   - JavaScript/TypeScript: `package.json`
   - Java: `pom.xml`, `build.gradle`
   - Go: `go.mod`
   - .NET: `*.csproj`, `packages.config`
   - Rust: `Cargo.toml`
   - Multi-ecosystem projects: scan ALL ecosystems

2. Locate and validate lockfiles:
   - Python: `poetry.lock`, `Pipfile.lock`, `requirements.txt` (pinned)
   - JavaScript: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - Java: `pom.xml` with resolved versions
   - Go: `go.sum`
   - .NET: `packages.lock.json`
   - Rust: `Cargo.lock`
   - If lockfile is missing or not committed to VCS, flag as a gap.

3. Extract the full dependency tree using the appropriate tool:

   | Ecosystem  | Scanning Tool                              | Configuration                               |
   | ---------- | ------------------------------------------ | ------------------------------------------- |
   | All        | FOSSA, Snyk, or Trivy                      | Run on every PR, block on policy violation  |
   | Python     | `pip-licenses` + `liccheck`                | `.liccheck.ini` with approved license list  |
   | JavaScript | `license-checker` or `license-webpack-plugin` | `.licensechecker.json` with policy        |
   | Java       | `license-maven-plugin`                     | `licenses.xml` with approved categories     |
   | Go         | `go-licenses`                              | Policy file with approved SPDX identifiers  |
   | .NET       | `dotnet-project-licenses`                  | NuGet license validation in CI              |

4. For each dependency in the tree, record:
   - Package name
   - Version (exact, from lockfile)
   - License SPDX identifier
   - Direct or transitive dependency
   - Package URL (purl)
   - Source repository URL (if available)
   - Hash value (SHA-256) from lockfile

5. Flag dependencies where the license cannot be automatically determined:
   - No LICENSE file in the package
   - Custom or non-standard license text
   - Conflicting license information between metadata and LICENSE file

6. Verify dependency integrity:
   - Package checksums match registry signatures
   - Lockfile hashes match resolved dependency tree
   - No discrepancies between manifest and lockfile

7. Check for typosquatting risks on newly added dependencies:
   - Review package names for similarity to popular packages
   - Check download counts, repository activity, and maintainer history
   - Verify organization-scoped packages where available (`@org/package`)

## VALIDATION

- [ ] All dependency manifests identified across all ecosystems
- [ ] Lockfiles present and committed to VCS
- [ ] Full dependency tree extracted (direct + transitive)
- [ ] Every dependency has a recorded license (or is flagged as Unknown)
- [ ] Dependency integrity verified (checksums, lockfile hashes)
- [ ] Newly added dependencies checked for typosquatting risks

