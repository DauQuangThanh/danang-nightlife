---
name: gen-test-plan
description: Creates comprehensive test plans covering unit, integration, and end-to-end testing from feature specifications and design artifacts. Generates structured test-plan.md and e2e-test-plan.md documents with test scenarios, acceptance criteria mapping, and Playwright E2E test scripts. Use when creating test strategies, planning E2E tests, mapping requirements to test cases, or when user mentions test plan, test strategy, E2E testing, Playwright tests, or quality assurance.
metadata:
  author: Dau Quang Thanh
  version: "1.0.0"
  last_updated: "2026-04-12"
license: MIT
---

# General Test Plan

## Overview

This skill creates comprehensive test plans from feature specifications and design artifacts. It generates structured test documents that map every requirement and user story to concrete test scenarios across unit, integration, and end-to-end (E2E) layers. For E2E testing, it produces Playwright-ready test scripts that can be executed via an MCP server or directly in CI/CD pipelines.

## When to Use

- Creating test strategies for new features or products
- Planning end-to-end tests with Playwright
- Mapping requirements and user stories to test cases
- Generating test scenarios from specifications and designs
- Preparing QA handoff documentation
- Defining acceptance criteria verification plans
- User mentions: "test plan", "test strategy", "E2E tests", "Playwright tests", "QA plan", "test coverage", "acceptance testing"

## Prerequisites

**Required:**

- Feature specification or requirements document available
- Bash 4.0+ (macOS/Linux/WSL) or PowerShell 5.1+ (Windows) for setup script
- Git repository with feature branch (format: `N-feature-name`)
- Feature directory at `specs/N-feature-name/` with `spec.md` file

**Recommended:**

- `specs/N-feature-name/design.md` — technical design with data models and API contracts
- `docs/ground-rules.md` — project principles and quality gates
- `docs/architecture.md` — architectural patterns and quality attribute targets
- `docs/standards.md` — testing standards and conventions

**Optional:**

- `specs/N-feature-name/contracts/` — API contracts for contract testing
- `specs/N-feature-name/data-model.md` — entities for data validation tests

## Instructions

### Step 0: Specification and Requirements Gathering

**⚠️ IMPORTANT: Always request specification documents before creating a test plan.**

1. **Request specification documents:**
   - Ask the user to provide feature specifications, requirements, or user stories
   - Request any relevant documentation: spec.md, design.md, API contracts
   - If no formal documentation exists, ask the user to describe:
     - The feature or system to be tested
     - Key user workflows and interactions
     - Expected inputs and outputs
     - Business rules and validation logic
     - Performance and reliability requirements
     - Security and compliance needs

2. **Verify project context exists:**
   - Check if `docs/ground-rules.md` exists (for quality gates and testing standards)
   - Check if `docs/architecture.md` exists (for quality attribute targets)
   - Check if `docs/standards.md` exists (for testing conventions)

3. **Review and confirm understanding:**
   - Summarize the testing scope back to the user
   - Clarify any ambiguities or missing details
   - Confirm expected test deliverables (test plan, E2E plan, or both)
   - Identify what testing layers are needed (unit, integration, E2E, performance)

4. **Only proceed to Step 1 after:**
   - Specification documents are provided and reviewed
   - Testing scope is clearly understood
   - User confirms readiness to create the test plan

### Step 1: Setup and Context Loading

1. **Run setup script** to create directory structure and copy templates:

   ```bash
   bash <SKILL_DIR>/scripts/check-prerequisites.sh --json              # macOS/Linux/WSL
   .\<SKILL_DIR>\scripts\check-prerequisites.ps1 -Json                 # Windows PowerShell
   ```

   Replace `<SKILL_DIR>` with the absolute path to this skill directory.

   The script will:
   - Verify you're on a feature branch (format: `N-feature-name`)
   - Check for required specification files
   - Copy test plan templates to the feature directory
   - Return JSON with paths: `feature_dir`, `spec_file`, `design_file`, `test_plan_file`, `e2e_test_plan_file`

2. **Load required context**:
   - Read feature specification (`spec.md`) — extract user stories, acceptance criteria, edge cases
   - Read technical design (`design.md`) if exists — extract API endpoints, data models, workflows
   - Read `docs/ground-rules.md` if exists — extract quality gates and testing requirements
   - Read `docs/architecture.md` if exists — extract quality attribute targets (latency, availability)
   - Read `docs/standards.md` if exists — extract testing conventions and frameworks
   - Read API contracts from `contracts/` if exists — extract endpoint schemas

### Step 2: Requirements-to-Test Mapping

**Goal**: Map every requirement and user story to concrete test scenarios.

1. **Extract testable requirements**:
   - Functional requirements from spec.md → functional test scenarios
   - Non-functional requirements → performance, security, accessibility test scenarios
   - User stories with acceptance criteria → acceptance test scenarios
   - Edge cases from spec.md → negative and boundary test scenarios

2. **Build traceability matrix**:

   | Requirement ID | Requirement Description | Test Type | Test Scenario ID | Priority |
   |---|---|---|---|---|
   | FR-001 | User can register with email | Unit, Integration, E2E | TS-001, TS-002, TS-003 | P1 |
   | NFR-001 | Registration < 500ms | Performance | TS-010 | P2 |

3. **Identify coverage gaps**:
   - Requirements without test scenarios → flag as gaps
   - Acceptance criteria without verification method → flag as incomplete
   - Edge cases without negative tests → add test scenarios

### Step 3: Generate Test Plan (test-plan.md)

**Goal**: Create the comprehensive test plan document.

Use `templates/test-plan-template.md` as the structure. Fill in:

#### Section 1: Test Strategy Overview

- Testing objectives aligned with project goals
- Testing scope (in-scope and out-of-scope)
- Testing layers and their responsibilities:
  - **Unit tests**: Individual functions, classes, business logic
  - **Integration tests**: API endpoints, database queries, service interactions
  - **E2E tests**: Complete user workflows through the UI
  - **Performance tests**: Latency, throughput, load (if required by NFRs)
- Testing tools and frameworks (per project standards)
- Entry and exit criteria

#### Section 2: Test Scenarios by User Story

For each user story (organized by priority P1, P2, P3...):

```markdown
### User Story [N]: [Title]

**Story**: [User story description]

**Acceptance Criteria**:
1. [AC-1]
2. [AC-2]

#### Unit Test Scenarios
- [ ] TS-U[N]01: [Test description] — validates [specific behavior]
- [ ] TS-U[N]02: [Test description] — validates [specific behavior]

#### Integration Test Scenarios
- [ ] TS-I[N]01: [Test description] — validates [API/service interaction]
- [ ] TS-I[N]02: [Test description] — validates [data persistence]

#### E2E Test Scenarios
- [ ] TS-E[N]01: [Test description] — validates [complete user workflow]

#### Negative/Edge Case Scenarios
- [ ] TS-N[N]01: [Test description] — validates [error handling]
- [ ] TS-N[N]02: [Test description] — validates [boundary condition]
```

#### Section 3: Non-Functional Test Scenarios

- Performance test scenarios (if NFRs exist)
- Security test scenarios (authentication, authorization, input validation)
- Accessibility test scenarios (if UI exists)

#### Section 4: Test Data Requirements

- Test data sets for each scenario
- Test user accounts and roles
- Mock data for external integrations
- Database seed data requirements

#### Section 5: Test Environment

- Environment configuration requirements
- External service dependencies and mocks
- Database setup and teardown procedures
- CI/CD integration points

#### Section 6: Traceability Matrix

- Complete requirements-to-test mapping table
- Coverage percentage per user story
- Overall coverage summary

### Step 4: Generate E2E Test Plan (e2e-test-plan.md)

**Goal**: Create a detailed E2E test plan with Playwright-ready test scenarios.

Use `templates/e2e-test-plan-template.md` as the structure. Fill in:

#### Section 1: E2E Testing Strategy

- Browser matrix (Chrome, Firefox, Safari, mobile viewports)
- Playwright configuration approach
- Test data management for E2E
- Screenshot and video capture strategy
- Retry and flakiness handling

#### Section 2: User Flow Test Scenarios

For each critical user flow:

```markdown
### Flow [N]: [Flow Name]

**Priority**: [P1/P2/P3]
**User Story**: [US reference]
**Preconditions**: [Required state before test]

#### Steps:
1. Navigate to [URL/page]
2. [Action]: [Specific interaction with element]
3. [Assertion]: Verify [expected outcome]
4. [Action]: [Next interaction]
5. [Assertion]: Verify [expected outcome]

#### Expected Results:
- [Final state after flow completes]
- [Data changes expected]
- [UI state expected]

#### Playwright Test Script:
```typescript
test('[Flow Name]', async ({ page }) => {
  // Step 1: Navigate
  await page.goto('/path');

  // Step 2: Interact
  await page.getByLabel('Email').fill('test@example.com');
  await page.getByRole('button', { name: 'Submit' }).click();

  // Step 3: Assert
  await expect(page.getByText('Success')).toBeVisible();
});
```

#### Variants:
- [ ] Happy path
- [ ] Error path: [specific error scenario]
- [ ] Edge case: [specific edge case]
```

#### Section 3: Cross-Browser and Responsive Tests

- Viewport-specific test scenarios
- Browser-specific test scenarios (if applicable)
- Mobile interaction patterns (touch, swipe)

#### Section 4: Visual Regression Tests

- Pages/components requiring visual snapshots
- Acceptable difference thresholds
- Baseline management approach

### Step 5: Validate and Cross-Reference

1. **Coverage validation**:
   - Every user story acceptance criterion has at least one test scenario
   - Every API endpoint has at least one integration test
   - Every critical user flow has an E2E test
   - Edge cases from spec.md have negative test scenarios

2. **Ground-rules compliance**:
   - Testing standards from ground-rules are followed
   - Quality gates are reflected in exit criteria
   - Coverage requirements are met

3. **Architecture alignment**:
   - Quality attribute targets have corresponding test scenarios
   - Performance SLOs have measurable test criteria
   - Security requirements have verification scenarios

### Step 6: Commit Test Plan Artifacts

1. **Stage all test plan files** (replace N-feature-name with actual feature branch name):

   ```bash
   git add specs/N-feature-name/test-plan.md
   git add specs/N-feature-name/e2e-test-plan.md
   ```

2. **Create commit with 'docs:' prefix**:

   ```bash
   git commit -m "docs: add test plan for N-feature-name"
   ```

3. **Report completion**:
   - List all generated artifacts with paths
   - Total test scenario count by type (unit, integration, E2E, negative)
   - Coverage percentage against requirements
   - Suggest next steps (implement tests, run E2E with Playwright MCP)

## Examples

### Example 1: User Authentication Feature

**Input**: Create test plan for user authentication with email/password and OAuth

**Process**:

1. Load spec.md → Extract 3 user stories (register, login, OAuth)
2. Load design.md → Extract API endpoints, data models
3. Map requirements → 12 unit, 8 integration, 5 E2E, 6 negative test scenarios
4. Generate test-plan.md with full traceability matrix
5. Generate e2e-test-plan.md with Playwright scripts for:
   - Registration flow (happy path + validation errors)
   - Login flow (happy path + invalid credentials)
   - OAuth callback flow (happy path + denied access)
6. Validate coverage: 100% acceptance criteria covered

**Output**: `test-plan.md` (31 scenarios), `e2e-test-plan.md` (5 flows with Playwright scripts)

### Example 2: E-Commerce Checkout

**Input**: Create test plan for checkout flow with payment processing

**Process**:

1. Load spec.md → Extract 4 user stories (cart, checkout, payment, confirmation)
2. Load contracts/ → Extract 6 API endpoints
3. Map requirements → 18 unit, 12 integration, 8 E2E, 10 negative test scenarios
4. Generate test-plan.md with payment-specific test data requirements
5. Generate e2e-test-plan.md with Playwright scripts for:
   - Add-to-cart flow, checkout flow, payment success/failure, order confirmation
6. Include Stripe test mode configuration and mock webhooks

**Output**: `test-plan.md` (48 scenarios), `e2e-test-plan.md` (8 flows with Playwright scripts)

## Key Rules

1. **Use Absolute Paths**: All file operations must use absolute paths
2. **Traceability Required**: Every test scenario MUST trace back to a requirement or user story
3. **Playwright for E2E**: All E2E test scripts MUST use Playwright syntax and best practices
4. **Actionable Scenarios**: Test scenarios must be specific enough to implement directly
5. **Priority Alignment**: Test priority must match user story priority (P1 stories get P1 tests)
6. **No Untested Requirements**: Flag any requirement without a test scenario as a coverage gap
7. **Respect Ground Rules**: Testing standards from ground-rules.md are non-negotiable
8. **Concrete Test Data**: Provide specific test data values, not placeholders
9. **Independent Tests**: E2E tests should be independent and not rely on execution order
10. **Clean State**: Every test scenario must define its preconditions and cleanup

## Edge Cases

### Case 1: No Design Document Available

**Handling**: Generate test plan from spec.md only. Focus on acceptance criteria and user story testing. Flag missing API contract tests as gaps.

### Case 2: Backend-Only Feature (No UI)

**Handling**: Skip E2E test plan generation. Focus on unit and integration test scenarios. Generate API test scripts instead of Playwright scripts.

### Case 3: Existing Test Suite

**Handling**: Read existing tests to understand patterns and conventions. Generate test plan that complements existing coverage. Note existing tests in traceability matrix.

### Case 4: Missing Acceptance Criteria

**Handling**: Flag user stories with missing acceptance criteria. Derive test scenarios from story description and known requirements. Mark as "NEEDS CLARIFICATION" in test plan.

### Case 5: Performance-Critical Feature

**Handling**: Add dedicated performance test section with load profiles, latency targets, and throughput requirements from architecture.md quality attributes.

## Error Handling

### Error: Feature Specification Not Found

**Action**: Report error, request user to create spec.md first using `gen-requirement-development` skill.

### Error: No User Stories in Specification

**Action**: Generate warning. Create test scenarios from functional requirements instead. Recommend adding user stories.

### Error: Conflicting Requirements

**Action**: Document conflict in test plan. Create test scenarios for both interpretations. Flag for resolution.

### Error: Template Not Found

**Action**: Create test plan from scratch following the section structure defined in this skill.

## Scripts

Cross-platform scripts for checking prerequisites:

```bash
bash <SKILL_DIR>/scripts/check-prerequisites.sh [--json]    # macOS/Linux/WSL
.\<SKILL_DIR>\scripts\check-prerequisites.ps1 [-Json]       # Windows PowerShell
```

### Script Output Format

Both scripts output JSON with:

- `success`: Boolean indicating if prerequisites are met
- `feature_dir`: Absolute path to feature directory
- `spec_file`: Path to spec.md
- `design_file`: Path to design.md (or null)
- `test_plan_file`: Path to test-plan.md output
- `e2e_test_plan_file`: Path to e2e-test-plan.md output
- `available_docs`: Array of found design documents
- `warning`: Warning message if recommended documents are missing

## Templates

- `templates/test-plan-template.md`: Structure for comprehensive test plan document
- `templates/e2e-test-plan-template.md`: Structure for E2E test plan with Playwright scripts

## Guidelines

1. **Coverage First**: Ensure every requirement has at least one test scenario before adding extras
2. **Pyramid Balance**: More unit tests than integration, more integration than E2E
3. **User Perspective**: E2E tests should mirror real user behavior, not technical implementation
4. **Flakiness Prevention**: E2E scenarios should use stable selectors (roles, labels, test IDs)
5. **Data Independence**: Each test should create its own data, never depend on other tests
6. **Architecture Alignment**: Test quality targets from architecture.md quality attributes
7. **Ground-Rules Compliance**: Follow testing standards from ground-rules.md
8. **Playwright Best Practices**: Use locator strategies (getByRole, getByLabel, getByTestId), auto-waiting, and web-first assertions

## Success Criteria

Test plan is complete when:

- [ ] **Specification reviewed**: All user stories and requirements analyzed
- [ ] **Traceability complete**: Every requirement maps to at least one test scenario
- [ ] **Test layers covered**: Unit, integration, and E2E scenarios defined
- [ ] **E2E flows scripted**: Playwright test scripts provided for critical user flows
- [ ] **Negative tests included**: Edge cases and error scenarios covered
- [ ] **Test data defined**: Concrete test data for each scenario
- [ ] **Ground-rules compliant**: Testing standards followed
- [ ] **Coverage gaps flagged**: Any untested requirements documented
- [ ] **Artifacts committed**: Test plan files committed with proper message

## Related Skills

**Before creating the test plan:**

- Use `gen-requirement-development` skill to create feature specifications
- Use `gen-technical-detailed-design` skill to create technical designs
- Use `gen-requirement-clarification` skill to resolve ambiguities

**After creating the test plan:**

- Use `gen-coding-plan` skill to include test tasks in implementation plan
- Use `gen-code-implementation` skill to implement the test scripts
- Use `gen-project-consistency-analysis` skill to validate test plan against specs and design
