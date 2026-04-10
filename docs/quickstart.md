# ⚡ Quick Start Guide

**Build your first project with Spec-Driven Development in 9 steps.**

---

## 🎯 The Workflow

Follow this order for best results. Tell your AI agent what you want to do and it will automatically pick the right skill — or reference the skill by name explicitly.

| Step | Skill | Purpose |
| ------ | ------- | --------- |
| 1️⃣ | `gen-project-ground-rules-setup` | Set ground rules (or `gen-codebase-assessment` for existing projects) |
| 2️⃣ | `gen-requirement-development` | Define requirements |
| 3️⃣ | `gen-requirement-clarification` | Clarify unclear requirements |
| 4️⃣ | `gen-architecture-design` | Design system architecture *(optional, product-level)* |
| 5️⃣ | `gen-coding-standards` | Create coding standards *(optional, product-level)* |
| 6️⃣ | `gen-technical-detailed-design` | Create implementation plan |
| 7️⃣ | `gen-coding-plan` | Break down into tasks |
| 8️⃣ | `gen-project-consistency-analysis` | Validate consistency and coverage |
| 9️⃣ | `gen-code-implementation` | Build it! |

> **💡 Smart Context:** Nightlife automatically detects your active feature from your Git branch (like `001-feature-name`). To work on different features, just switch branches.

---

## 🚀 Let's Build Something

### Step 1: Install Nightlife

Run this in your terminal:

```bash
# Create a new project
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init <PROJECT_NAME>

# OR work in current directory
uvx --from git+https://github.com/dauquangthanh/danang-nightlife.git nightlife init .
```

---

### Step 2: Set Your Rules

Tell your AI agent to set up ground rules:

> *"Use the `gen-project-ground-rules-setup` skill. This project follows a 'Library-First' approach. All features must be implemented as standalone libraries first. We use TDD strictly. We prefer functional programming patterns."*

**What this does:** Creates `docs/ground-rules.md` with principles that guide all future development decisions.

---

### Step 3: Write Your Specification

Describe **what** you want (not **how** to build it):

> *"Use the `gen-requirement-development` skill. Build a photo organizer app. Albums are grouped by date and can be reorganized by drag-and-drop. Each album shows photos in a tile view. No nested albums allowed."*

**Focus on:** User needs, features, and behavior — skip tech stack details for now.

### Step 4: Design System Architecture *(Optional)*

Document your overall system design (do this once per product):

> *"Use the `gen-architecture-design` skill. Document the system architecture including C4 diagrams, microservices design, and technology stack decisions."*

---

### Step 5: Set Coding Standards *(Optional)*

Create team coding conventions (do this once per product):

> *"Use the `gen-coding-standards` skill. Create comprehensive coding standards for TypeScript and React, including naming conventions and best practices."*

---

### Step 6: Refine Your Spec *(Optional)*

Clarify any unclear requirements:

> *"Use the `gen-requirement-clarification` skill. Focus on security and performance requirements."*

---

### Step 7: Create Technical Design

Now specify **how** to build it (tech stack and architecture):

> *"Use the `gen-technical-detailed-design` skill. Use Vite with minimal libraries. Stick to vanilla HTML, CSS, and JavaScript. Store metadata in local SQLite. No image uploads."*

**What to include:** Tech stack, frameworks, libraries, database choices, architecture patterns.

---

### Step 8: Break Down & Build

**Create tasks:**

> *"Use the `gen-coding-plan` skill."*

**Validate the plan (optional):**

> *"Use the `gen-project-consistency-analysis` skill."*

**Build it:**

> *"Use the `gen-code-implementation` skill."*

**What happens:** Your AI agent executes all tasks in order, building your application according to the plan.

---

## 📖 Complete Example: Building Taskify

**Project:** A team productivity platform with Kanban boards.

### 1. Set Ground Rules

> *"Use the `gen-project-ground-rules-setup` skill. Taskify is 'Security-First'. Validate all user inputs. Use microservices architecture. Document all code thoroughly."*

### 2. Define Requirements

> *"Use the `gen-requirement-development` skill. Build Taskify, a team productivity platform. Users can create projects, add team members, assign tasks, comment, and move tasks between Kanban boards. Start with 5 predefined users: 1 product manager and 4 engineers. Create 3 sample projects. Use standard Kanban columns: To Do, In Progress, In Review, Done. No login required for this initial version."*

### 3. Refine with Details

> *"Use the `gen-requirement-clarification` skill. For task cards: users can change status by dragging between columns, leave unlimited comments, and assign tasks to any user. Show a user picker on launch. Clicking a user shows their projects. Clicking a project opens the Kanban board. Highlight tasks assigned to current user in different color. Users can edit/delete only their own comments."*

### 4. Create Technical Plan

> *"Use the `gen-technical-detailed-design` skill. Use .NET Aspire with Postgres database. Frontend: Blazor server with drag-and-drop and real-time updates. Create REST APIs for projects, tasks, and notifications."*

### 5. Validate and Build

> *"Use the `gen-project-consistency-analysis` skill."*

> *"Use the `gen-code-implementation` skill."*

---

## 🎯 Key Principles

| Principle | What It Means |
| ----------- | --------------- |
| **Be Explicit** | Clearly describe what and why you're building |
| **Skip Tech Early** | Don't worry about tech stack during specification |
| **Iterate** | Refine specs before implementation |
| **Validate First** | Check the plan before coding |
| **Let AI Work** | Trust the agent to handle implementation details |

---

## 📚 Next Steps

**Learn more:**

- 📖 [Installation Guide](installation.md) - Detailed setup options
- 🔍 [Upgrade Guide](upgrade.md) - Update to the latest version
- 💻 [Source Code](https://github.com/dauquangthanh/danang-nightlife) - Contribute to the project

**Get help:**

- 🐛 [Report Issues](https://github.com/dauquangthanh/danang-nightlife/issues/new) - Found a bug?
- 💬 [Ask Questions](https://github.com/dauquangthanh/danang-nightlife/discussions) - Need help?
