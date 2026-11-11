# Hearth

**Stay warm. Think clearly.**

Hearth is a local app that helps you make smarter, better-informed calls on prediction markets. It lines up your
picks, shows how likely each outcome is, and tracks whether your thinking pays off.

> Status: early development. Nothing here is finished, and Hearth does not place real trades.
> Hearth is not financial advice. See [DISCLAIMER.md](DISCLAIMER.md).

## Developing

Windows, from PowerShell in this folder:

    .\scripts\setup-dev.ps1

This creates a virtual environment, installs the tools, turns on the pre-commit safety checks and runs the tests.

Branches: `main` (production), `qc` (testing) and `dev` (daily work). Merges into `qc` and `main` go through pull
requests, and the CI workflow (`.github/workflows/ci.yml`) runs the checks and tests on every pull request.

Install instructions for end users will be written later.

## Layout

| Folder | Purpose |
| --- | --- |
| `src/hearth/` | The app |
| `tests/` | Automated tests |
| `docs/` | Decisions, spec, architecture, roadmap |
| `CLAUDE.md` | Standing instructions for Claude Code |
| `deploy/` | Docker, installer and monitoring (added later) |
| `.github/workflows/` | Automatic checks that run on pull requests |
| `scripts/` | Developer helper scripts |
