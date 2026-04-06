# Step 5: Generate SBOM

## RULES

- Every release MUST include an SBOM in CycloneDX or SPDX format.
- SBOMs MUST be generated during CI build, not manually.
- SBOMs MUST be regenerated on every dependency update.
- SBOM generation failure MUST NOT be skipped. Fix the tool configuration before proceeding.
- Stale SBOMs (older than the build) trigger a blocking review.

## INSTRUCTIONS

1. Select the appropriate SBOM generation tool for each ecosystem:

   | Ecosystem  | SBOM Tool                                          | Output Format    |
   | ---------- | -------------------------------------------------- | ---------------- |
   | Python     | `cyclonedx-python`                                 | CycloneDX JSON   |
   | JavaScript | `cyclonedx-npm` or `@cyclonedx/webpack-plugin`     | CycloneDX JSON   |
   | Java       | `cyclonedx-maven-plugin`                           | CycloneDX XML/JSON|
   | Go         | `cyclonedx-gomod`                                  | CycloneDX JSON   |
   | .NET       | `cyclonedx-dotnet`                                 | CycloneDX JSON   |
   | Container  | `syft` or `trivy`                                  | SPDX / CycloneDX |

2. Generate the SBOM and verify it contains all required fields:
   - Component name, version, and SPDX license identifier
   - Package URL (purl) for each component
   - Dependency relationship graph (direct and transitive)
   - Hash values (SHA-256) for component verification
   - Supplier/author information where available
   - Known vulnerabilities mapped to each component (VEX)

3. Validate the SBOM against the template at [../templates/sbom-template.md](../templates/sbom-template.md).

4. Verify the SBOM lifecycle is implemented:
   - SBOM generated during CI build (not manually)
   - SBOM stored as a build artifact alongside the release
   - SBOM published to internal registry for dependency tracking
   - SBOMs from upstream vendors consumed for supply chain visibility
   - SBOMs monitored against vulnerability databases continuously
   - SBOM regenerated on every dependency update

5. For CI integration, verify the pipeline includes SBOM generation:

   Example Python CI:
   ```yaml
   # .github/workflows/license-check.yml
   name: License Check
   on: [pull_request]
   jobs:
     license-scan:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-python@v5
           with:
             python-version: "3.12"
         - run: pip install pip-licenses liccheck
         - run: pip install -r requirements.txt
         - run: pip-licenses --format=json --output-file=licenses.json
         - run: liccheck -s .liccheck.ini -r requirements.txt
   ```

   Example release SBOM generation:
   ```yaml
   # .github/workflows/sbom.yml
   name: Generate SBOM
   on:
     push:
       tags: ["v*"]
   jobs:
     sbom:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - name: Generate CycloneDX SBOM
           uses: CycloneDX/gh-dotnet-generate-sbom@v1
           with:
             path: ./src/Api/Api.csproj
             output: ./sbom.json
         - name: Upload SBOM as release artifact
           uses: actions/upload-artifact@v4
           with:
             name: sbom
             path: ./sbom.json
   ```

6. Cross-reference the SBOM against the license matrix from Step 2:
   - Every component in the SBOM must have a corresponding license classification
   - Flag any components in the SBOM that are not in the license matrix (new/unexpected dependencies)

7. If SBOM generation fails:
   - Do NOT skip the step
   - Diagnose and fix the tool configuration
   - Document the failure and resolution
   - Missing SBOMs break supply chain compliance

## VALIDATION

- [ ] SBOM generated in CycloneDX or SPDX format
- [ ] SBOM contains all required fields (name, version, license, purl, hashes, relationships)
- [ ] SBOM includes both direct and transitive dependencies
- [ ] SBOM generation is integrated into CI pipeline
- [ ] SBOM is stored as a build artifact
- [ ] SBOM components cross-referenced against license matrix
- [ ] No unexpected/unclassified components in the SBOM
- [ ] SBOM is current (not stale)

