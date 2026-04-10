# Project: nightlife-cli

Nightlife CLI — A framework to develop your project with Spec-Driven Development (SDD), part of the Danang Nightlife Project.

## Tech Stack

- **Language:** Python 3.11+
- **Framework:** Typer + Rich (CLI)
- **Build Tool:** Hatch (hatchling backend)
- **Package Manager:** pip
- **Key Dependencies:** typer, rich, httpx, platformdirs, readchar, truststore

## Project Structure

```text
├── agents/                  # Agent persona definitions
│   └── business-analyst.md
├── skills/                  # Shared agent skills (19 skills)
├── .claude/
│   └── skills/              # Claude Code-specific skills (3 skills)
├── src/
│   └── nightlife_cli/       # Main Python package
│       ├── __init__.py
│       ├── __main__.py
│       ├── commands.py
│       ├── config.py
│       ├── github.py
│       ├── system_utils.py
│       ├── templates.py
│       └── ui.py
├── docs/                    # Documentation (DocFX)
├── templates/               # Agent file templates
├── .github/workflows/       # CI/CD (docs, lint, release)
└── pyproject.toml
```

## Development Commands

- **Install:** `pip install -e .`
- **Run CLI:** `nightlife`
- **Build:** `hatch build`
- **Lint:** See `.github/workflows/lint.yml`

## Coding Conventions

- Package source lives under `src/nightlife_cli/`
- CLI entry point is `nightlife_cli:main` (registered in `[project.scripts]`)
- Uses conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`)

## Important Notes

- The project follows a Spec-Driven Development (SDD) workflow
- Agent skills in `skills/` are cross-platform; skills in `.claude/skills/` are Claude Code-specific
- Documentation is built with DocFX (see `docs/docfx.json`)
