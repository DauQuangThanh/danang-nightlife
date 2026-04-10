<!-- TEMPLATE START -->
# Agent Personas and Protocols

## 1. Overview
This project utilizes an agentic workflow. All agents must adhere to the `{{SPEC_DIR}}` guidelines and use the `main` branch for all PRs.

## 2. Project Structure

```text
[ACTUAL STRUCTURE]
```

## 3. Agent Definitions

### {{AGENT_NAME: e.g., Architect-Agent}}
* **Primary Role:** {{High-level purpose}}
* **Context Scope:** Deep access to `{{DOCS_PATH}}` and system architecture diagrams.
* **Constraint:** Must not modify code without an approved `{{DESIGN_SPEC}}`.
* **Primary Tools:** {{e.g., MCP Search, File System, Diagram Generator}}

### {{AGENT_NAME: e.g., Feature-Agent}}
* **Primary Role:** Implementation of specific features.
* **Context Scope:** `src/` directory and relevant unit tests.
* **Tools:** {{e.g., uv, Node.js runtime, Git}}

## 4. Communication Protocols
* **Handoffs:** When {{CONDITION}}, Agent A must signal Agent B using {{METHOD}}.
* **Validation:** All code must be validated against `{{TEST_SUITE}}` before completion.

## 5 Recent Changes

[LAST 3 FEATURES AND WHAT THEY ADDED]

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->

<!-- TEMPLATE END -->
