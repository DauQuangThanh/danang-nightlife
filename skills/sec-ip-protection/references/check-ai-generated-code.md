# Step 4: Check AI-Generated Code

## RULES

- All AI-generated code MUST be marked with `// AI-GENERATED` comment.
- AI-generated code undergoes the SAME review standard as human-written code.
- AI may reproduce training data verbatim. All AI-generated code MUST be checked for similarity to known open-source code.
- Enable "block suggestions matching public code" filters where available (e.g., GitHub Copilot).
- Prefer AI assistance for boilerplate, tests, and documentation over core business logic.

## INSTRUCTIONS

1. Identify AI-generated code in the repository:
   - Search for `// AI-GENERATED`, `# AI-GENERATED`, `/* AI-GENERATED */` markers
   - Check commit messages for AI assistant references (Copilot, Claude, ChatGPT, etc.)
   - Review PR descriptions for mentions of AI-assisted development
   - Check for AI tool configuration files (`.github/copilot-*`, `.cursorrules`, etc.)

2. For each identified AI-generated code block, verify:

   | Control                        | Implementation                                                |
   | ------------------------------ | ------------------------------------------------------------- |
   | Disclosure                     | Code is marked with `// AI-GENERATED` comment                 |
   | Review                         | Code has been reviewed by a human (PR review record)          |
   | License risk                   | Checked for patterns matching known open-source code          |
   | Copilot filter                 | "Block suggestions matching public code" enabled (if applicable)|
   | Substantial copying detection  | Similarity check run against popular open-source repositories |
   | Non-critical path preference   | AI used for boilerplate, tests, docs (not core IP)            |

3. Run similarity detection on AI-generated code:
   - Compare against popular open-source repositories in the same language/framework
   - Check for verbatim reproduction of distinctive code patterns
   - Flag any matches with similarity score above threshold
   - For flagged code: determine the license of the matched source and assess compatibility

4. Assess the IP risk level of AI-generated code:
   - **Low risk**: Boilerplate, configuration, standard patterns, tests, documentation
   - **Medium risk**: Utility functions, common algorithms, data transformations
   - **High risk**: Core business logic, novel algorithms, competitive differentiators
   - Document the risk level for each significant AI-generated code block

5. Verify AI tool configuration:
   - GitHub Copilot: check if "Suggestions matching public code" is set to "Block"
   - Other AI tools: check for equivalent public code matching filters
   - Document the configuration in the origin report

6. For AI-generated code without proper marking:
   - Flag as a gap requiring remediation
   - Add `// AI-GENERATED` markers retroactively where AI origin can be determined from commit history
   - For code where AI origin is uncertain, document as "origin unclear" and flag for review

7. Check that AI-generated code does not introduce:
   - Code patterns from GPL/AGPL-licensed projects
   - Proprietary code from training data (API keys, internal URLs, company-specific patterns)
   - Security vulnerabilities (review for OWASP Top 10 patterns)

## VALIDATION

- [ ] All AI-generated code in the repository is identified
- [ ] AI-generated code is marked with `// AI-GENERATED` comment
- [ ] AI-generated code has been reviewed by a human
- [ ] Similarity detection has been run against known open-source repositories
- [ ] No verbatim reproduction of restrictively-licensed code found
- [ ] AI tool configurations enforce public code matching filters
- [ ] IP risk level documented for significant AI-generated blocks
- [ ] Unmarked AI-generated code flagged as gaps

