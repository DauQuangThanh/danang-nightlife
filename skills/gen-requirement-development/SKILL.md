---
name: gen-requirement-development
description: "Creates feature specifications from natural language descriptions with testable requirements and acceptance criteria. Use when defining new features, writing product requirements, or when user mentions specifications, requirements gathering, or feature definition."
metadata:
  author: Dau Quang Thanh
  version: "1.3.0"
  last_updated: "2026-02-08"
license: MIT
---

# General Requirements Specification

## Overview

This skill creates or updates feature specifications from natural language descriptions, generating structured documentation with testable requirements, user stories, and acceptance criteria. It validates specification quality and ensures requirements are unambiguous and complete.

## When to Use

Use this skill when:

- Creating a new feature specification from a user description
- Converting natural language requirements into structured specifications
- Documenting product requirements for stakeholders
- Validating specification quality and completeness
- Ensuring requirements are testable and unambiguous
- User mentions: specs, requirements, feature definition, user stories, acceptance criteria

**Next Steps After Creating Specifications:**

- Use `gen-architecture-design` skill for system architecture documentation
- Use `gen-technical-detailed-design` skill for feature-level implementation planning
- Use `gen-nextjs-mockup` or `gen-nuxtjs-mockup` skill to prototype the UI before committing to full design (recommended for features with significant UX complexity)

## Prerequisites

**Required Tools:**

- Git (for branch management)
- Bash 4.0+ (macOS/Linux/WSL) or PowerShell 5.1+ (Windows)
- Text editor or file system access

**Required Files:**

- `templates/spec-template.md` (specification template - provided with this skill)
- `templates/checklist-template.md` (checklist template - provided with this skill)
- Scripts: `scripts/create-feature.sh` (Bash) or `scripts/create-feature.ps1` (PowerShell)

**Optional Context Files:**

- `docs/architecture.md` (for technology stack and architectural patterns)
- `docs/standards.md` (for naming conventions and coding standards)

## Instructions

### Step 0: Ground Rules Verification

**⚠️ IMPORTANT: Always verify ground rules exist before creating feature specifications.**

1. **Check for ground rules document:**
   - Look for `docs/ground-rules.md` in the workspace
   - Ground rules define project principles, constraints, and standards
   - These are essential for creating aligned specifications

2. **If ground rules are missing:**
   - **STOP** and inform the user: "Ground rules document not found at `docs/ground-rules.md`"
   - Recommend: "Please set up project ground rules first using the `project-ground-rules-setup` skill"
   - Ask: "Would you like me to help set up ground rules before creating this specification?"
   - Wait for user decision:
     - If user wants to set up ground rules → guide them to use `project-ground-rules-setup` skill
     - If user wants to proceed anyway → ask for confirmation and document this decision
     - If unsure → explain the importance of ground rules for consistency

3. **If ground rules exist:**
   - Read and review `docs/ground-rules.md`
   - Extract key principles and constraints
   - Note any relevant standards or conventions
   - Use these to guide specification creation

4. **Only proceed to Step 1 after:**
   - Ground rules are reviewed (if they exist), OR
   - User explicitly confirms to proceed without ground rules (with understanding of risks)

### Step 1: Extract Feature Short Name

Analyze the feature description and generate a concise short name (2-4 words):

1. **Extract meaningful keywords** from the description
2. **Use action-noun format** when possible (e.g., "add-user-auth", "fix-payment-bug")
3. **Preserve technical terms** and acronyms (OAuth2, API, JWT, etc.)
4. **Keep it descriptive** but concise enough to understand at a glance

**Examples:**

- "I want to add user authentication" → `user-auth`
- "Implement OAuth2 integration for the API" → `oauth2-api-integration`
- "Create a dashboard for analytics" → `analytics-dashboard`
- "Fix payment processing timeout bug" → `fix-payment-timeout`

### Step 2: Check for Existing Branches

Before creating a new branch, find the highest feature number for this short name:

```bash
# Fetch all remote branches
git fetch --all --prune

# Find highest number across all sources
# Remote branches
git ls-remote --heads origin | grep -E "refs/heads/[0-9]+-<short-name>$"

# Local branches
git branch | grep -E "^[* ]*[0-9]+-<short-name>$"

# Specs directories
ls -d specs/[0-9]*-<short-name> 2>/dev/null || true
```

**Determine next number:**

- Extract the numeric prefix from each matching branch/directory name
- Parse each prefix as an integer (strip leading zeros: `001` → `1`, `010` → `10`)
- Find the highest integer N across all sources
- Use N+1 for the new branch number
- If no existing branches/directories found, start with number 1
- Format the final number as a zero-padded 3-digit string: `1` → `001`, `10` → `010`

### Step 3: Run Feature Creation Script

Execute the appropriate script with the calculated number and short-name:

**Bash:**

```bash
<SKILL_DIR>/scripts/create-feature.sh --json --number <N+1> --short-name "<short-name>" "<feature description>"
```

**PowerShell:**

```powershell
.\<SKILL_DIR>\scripts\create-feature.ps1 -Json -Number <N+1> -ShortName "<short-name>" "<feature description>"
```

Replace `<SKILL_DIR>` with the absolute path to this skill directory.

**Important Notes:**

- Only run this script once per feature
- The JSON output contains BRANCH_NAME and SPEC_FILE paths
- For single quotes in args, use escape syntax: `'I'\''m Groot'` or use double quotes: `"I'm Groot"`
- The script creates and checks out a new branch, creates directories, and copies templates

### Step 4: Load Product Context (Optional)

If available in the workspace, load product-level context to ensure alignment:

1. **Read `docs/architecture.md`** (if exists) — technology stack, architectural patterns, quality requirements
2. **Read `docs/standards.md`** (if exists) — naming conventions, coding standards, best practices

**Note**: This step is optional. The skill works independently without these files.

### Step 5: Create Specification

Follow this execution flow to create the specification:

1. **Parse User Description**
   - Extract from user input
   - If empty, return error: "No feature description provided"

2. **Extract Key Concepts**
   - Identify: actors, actions, data, constraints
   - Document in appropriate spec sections

3. **Handle Unclear Aspects**
   - **Make informed guesses** based on context and industry standards
   - **Only mark with [NEEDS CLARIFICATION: specific question]** if:
     - Choice significantly impacts scope or user experience
     - Multiple reasonable interpretations exist with different implications
     - No reasonable default exists
   - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
   - **Priority**: scope > security/privacy > user experience > technical details

4. **Fill User Scenarios & Testing**
   - Define user flows
   - Create acceptance scenarios
   - If no clear user flow, return error: "Cannot determine user scenarios"

5. **Generate Functional Requirements**
   - Each requirement must be testable
   - Use reasonable defaults for unspecified details
   - Document assumptions in Assumptions section

6. **Define Success Criteria**
   - Create measurable, technology-agnostic outcomes
   - Include quantitative metrics (time, performance, volume)
   - Include qualitative measures (user satisfaction, task completion)
   - Each criterion must be verifiable without implementation details

7. **Identify Key Entities** (if data involved)

The script creates the initial spec file from `templates/spec-template.md`. Now enhance it:

1. The template is already copied to SPEC_FILE by the script
2. Replace placeholders with concrete details from feature description
3. Preserve section order and headings
4. Ensure consistency with architecture.md and standards.md (if they exist in workspace)
5. Fill in all mandatory sections

**Section Requirements:**

- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant
- **When section doesn't apply**: Remove it entirely (don't leave as "N/A")

### Step 6: Validate Specification Quality

Create and use a quality checklist to validate the specification. For detailed validation criteria and examples, see [references/specification-guide.md](references/specification-guide.md).

#### 6a. Create Spec Quality Checklist

Generate a checklist file at `<FEATURE_DIR>/checklists/requirements.md`:

```markdown
# Specification Quality Checklist: [FEATURE NAME]

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: [DATE]
**Feature**: [Link to spec.md]

## Content Quality

- [ ] No implementation details (languages, frameworks, APIs)
- [ ] Focused on user value and business needs
- [ ] Written for non-technical stakeholders
- [ ] All mandatory sections completed

## Requirement Completeness

- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Success criteria are technology-agnostic
- [ ] All acceptance scenarios are defined
- [ ] Edge cases are identified
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

## Feature Readiness

- [ ] All functional requirements have clear acceptance criteria
- [ ] User scenarios cover primary flows
- [ ] Feature meets measurable outcomes defined in Success Criteria
- [ ] No implementation details leak into specification

## Notes

- Items marked incomplete require spec updates before next phase
```

#### 6b. Run Validation Check

Review the spec against each checklist item. See [references/specification-guide.md](references/specification-guide.md) for detailed validation criteria, common failures, and fix strategies.

#### 6c. Handle Validation Results

**If all items pass:** Mark checklist complete and proceed to final commit.

**If items fail:** Update spec to address issues, re-run validation (max 3 iterations). See [references/specification-guide.md](references/specification-guide.md) for iteration strategy.

**If [NEEDS CLARIFICATION] markers remain:** Present clarification questions to user (max 3). See [references/specification-guide.md](references/specification-guide.md) for question format.

#### 6d. Update Checklist

After each validation iteration, update the checklist file with current pass/fail status.

### Step 7: Commit Specification

Generate a 'docs:' prefixed git commit message and commit:

```bash
git add <SPEC_FILE> <CHECKLIST_FILE>
git commit -m "docs: add specification for <feature-name>"
```

### Step 8: Report Completion

Report to user with:

- Branch name
- Spec file path
- Checklist results summary
- Readiness for next phase (clarification, architecture, or technical design)

### Step 9: Quality Review (Recommended)

**After completing the specification, it's highly recommended to run a quality review:**

1. **Run the `gen-requirement-clarification` skill** to validate:
   - Completeness of all sections
   - Consistency with ground rules and architecture
   - Testability of requirements
   - Clarity and lack of ambiguity
   - Proper acceptance criteria

2. **Address any findings** from the review before proceeding to technical design

3. **If issues found**, update the specification and repeat validation

**Next Steps:**

- If review passes, proceed to architecture (if new product) or technical design (if adding feature)
- Use `gen-architecture-design` skill for new product architecture
- Use `gen-technical-detailed-design` skill for feature implementation planning

## Examples

### Example 1: Simple Feature

**Input**: "Add user login with email and password"

**Processing**:

1. Short name: `user-login`
2. Branch: `1-user-login` (no existing branches)
3. Spec created with user scenarios, functional requirements, success criteria
4. All validations pass

**Output**: Ready for technical design phase

### Example 2: Feature Requiring Clarification

**Input**: "Add payment processing"

**Processing**:

1. Initial spec created with [NEEDS CLARIFICATION] for payment methods
2. User responds with choice
3. Spec updated and re-validated

**Output**: Ready for next phase

See [references/specification-guide.md](references/specification-guide.md) for detailed examples of good vs bad specifications.

## Edge Cases

### Case 1: Branch Already Exists

Find highest existing number and increment. Document relationship in spec.

### Case 2: Empty or Vague Description

Ask clarifying questions about what the feature should do, who will use it, and what problem it solves.

### Case 3: Script Execution Fails

Check error output, resolve common issues, or create branch/directories manually.

### Case 4: Too Many Clarification Markers

Prioritize by impact (scope > security > UX > technical), keep top 3, make informed guesses for rest. Document assumptions.

See [references/specification-guide.md](references/specification-guide.md) for detailed edge case handling.

## Guidelines

### Focus on WHAT and WHY, Not HOW

Specifications should describe user needs and business value, not implementation details. See [references/specification-guide.md](references/specification-guide.md) for detailed examples of good vs bad specifications.

**DO:**

- "Users can reset their password via email"
- "System supports 10,000 concurrent users"
- "Search results appear in under 1 second"

**DON'T:**

- "Use bcrypt for password hashing" (implementation detail)
- "Store sessions in Redis" (technology choice)
- "Implement with React hooks" (framework-specific)

### Success Criteria Requirements

See [references/specification-guide.md](references/specification-guide.md) for detailed criteria properties and examples.

1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-agnostic**: No frameworks, languages, databases, or tools
3. **User-focused**: Outcomes from user/business perspective
4. **Verifiable**: Can be tested without knowing implementation

### Reasonable Defaults and Clarification Usage

See [references/specification-guide.md](references/specification-guide.md) for comprehensive lists of reasonable defaults and detailed clarification guidelines.

**Reasonable Defaults** (don't ask about these):

- Data retention, performance targets, error handling
- Authentication methods, integration patterns
- Standard industry practices

**Use [NEEDS CLARIFICATION] only when**:

- Scope impact, security/privacy implications
- Multiple valid interpretations, fundamental UX differences
- **Limit**: Maximum 3 clarification markers per feature

## Error Handling

For common errors and their resolutions:

### Error: "No feature description provided"

**Action**: Prompt user for feature description and proceed once provided.

### Error: "Cannot determine user scenarios"

**Action**: Ask user who will use the feature and what they're trying to accomplish.

### Error: "Template file not found"

**Action**: Check skill templates folder, or use generic spec structure with required sections.

### Error: "Script execution failed"

**Action**: Parse output for error, resolve common issues (git config, permissions, invalid args), or create branch/directories manually if needed.

### Error: "Validation failed after 3 iterations"

**Action**: Document failing items in checklist notes, provide detailed explanation to user, suggest manual review. See [references/specification-guide.md](references/specification-guide.md) for detailed validation guidance and common failure fixes.

## Scripts

Feature creation scripts (cross-platform):

- **scripts/create-feature.sh**: Bash script for macOS/Linux/WSL
- **scripts/create-feature.ps1**: PowerShell script for Windows

```bash
bash <SKILL_DIR>/scripts/create-feature.sh --number 5 --short-name "user-auth" "Add user authentication"
.\<SKILL_DIR>\scripts\create-feature.ps1 -Number 5 -ShortName "user-auth" -Description "Add user authentication"
```

Both scripts create Git branches, generate spec.md and checklist.md from templates, replace placeholders, and support JSON output.

## Quality Checklist

Before considering specification complete:

- [ ] Ground rules reviewed and aligned with specification
- [ ] Short name validated and branch created with proper naming
- [ ] Spec template populated with functional requirements
- [ ] User scenarios and acceptance criteria defined
- [ ] Success criteria established (measurable, technology-agnostic)
- [ ] Edge cases and assumptions documented
- [ ] Quality validation checklist completed (Step 6)
- [ ] No [NEEDS CLARIFICATION] markers remain (or clarified)
- [ ] Specification committed with proper commit message
- [ ] Ready for `gen-requirement-clarification` skill

## Additional Resources

For more detailed information:

- [references/specification-guide.md](references/specification-guide.md) - Detailed specification writing guide, validation criteria, and examples
- [templates/spec-template.md](templates/spec-template.md) - Complete specification template with all sections
- [templates/checklist-template.md](templates/checklist-template.md) - Quality validation checklist template
