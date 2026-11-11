# CLAUDE.md: standing instructions for Claude Code in this repo

Hearth: a local Windows app that helps one person make better-informed calls on Kalshi sports markets and tracks
whether those calls work out. Read `docs/SPEC.md` (what to build) and `docs/decisions.md` (what is decided) before
starting any feature. If they conflict with a request, say so and ask before proceeding.

## Hard rules (never break these)
- Never place, simulate placing, or prepare real orders or trades. v1 has no Kalshi account keys at all.
- Never read, print, log, copy or commit `.env`, anything in `secrets/`, or any `*.pem` or `*.key` file.
- Never commit or push directly to `dev`, `qc` or `main`. Never open a pull request into `main`. Never merge pull requests.
  Never force-push, rewrite history, or use `--no-verify`.
- Replay and predictions must never use data observed after their as-of time. Query by as-of time, always.
- Observations are append-only: never overwrite or delete saved prices, odds or predictions.
- Never make a network call while a database write transaction is open.
- Do not add a dependency, change CI or workflows, or change a GitHub ruleset without asking first.

## Stack and commands (Windows, PowerShell)
Python 3.12, SQLite (WAL mode), SQLAlchemy and Alembic, pytest, ruff. Use the project environment:
- Set up everything: `.\scripts\setup-dev.ps1`
- Tests: `.\.venv\Scripts\python.exe -m pytest`
- Lint: `.\.venv\Scripts\python.exe -m ruff check .`
- All checks: `.\.venv\Scripts\python.exe -m pre_commit run --all-files`

In a cloud session (a Linux machine, not Windows), the PowerShell commands above do not apply. Use:
`python -m pip install -e ".[dev]"`, then `pytest`, `ruff check .` and `pre-commit run --all-files`.
Cloud sessions cannot test Windows-specific behavior, run Ollama, or open the dashboard on the user's machine, so
keep that work for local sessions. Always work on a branch and push that branch; never push to `dev`, `qc` or `main`.

## Git workflow
- Branches: `main` (production), `qc` (full quality-control testing), `dev` (integration: finished features land here
  and are checked for major problems).
- All work happens on short-lived branches created from an up-to-date `dev`: `feature/<short-name>` for new work,
  `fix/<short-name>` for fixes, `chore/<short-name>` for docs and tooling. Never commit directly to `dev`, `qc` or `main`.
- Commit small and often with clear messages. Before each commit, tests and pre-commit must pass. Push the branch to GitHub.
- Pull requests: open one only when the user asks. A feature branch goes into `dev`. Promotion from `dev` goes into `qc`.
  Never open a pull request into `main`, and never merge any pull request. The user moves `qc` into `main`.
- Shared instructions (`CLAUDE.md`, `docs/SPEC.md`, `docs/decisions.md`) change on their own small branch that is merged
  into `dev` first, so every later branch inherits them. Do not change them on a feature branch unless the task is
  about them. If they need changing, tell the user.
- Tell the user when a branch is ready.

## Database rules
1. SQLite in WAL mode with a busy timeout and synchronous=NORMAL.
2. One writer: only the background collector writes. The dashboard only reads.
3. Keep write transactions short.
4. The database file lives in `%LOCALAPPDATA%\Hearth\`, never in the repo or a synced folder.
5. Backups use SQLite's backup function, not a file copy.
6. Every observation has an as-of timestamp in UTC. Prices are whole cents (integers).
7. Change the schema only through Alembic migrations.

## Code conventions
- Type hints, small functions, a test for every module. Tests must not call real network services; use recorded samples.
- Leagues are plug-ins on one shared engine. League-specific code never leaks into the engine.
- No hard-coded paths. Settings come from environment variables or a settings file, with safe defaults.
- Logs never contain secrets. Respect each data source's rate limits and cache responses.
- Verify an API's current behavior in its documentation before relying on it, and note the source and date.

## How to work with the user
- The user works in the Claude desktop app (Code tab), choosing Local or Cloud sessions. Describe steps for that app, not the terminal CLI.
- The user is comfortable running commands but is not a professional developer. Explain what you are doing in
  plain language, in small steps, and give PowerShell commands for anything the user must run.
- Ask before making a decision that is hard to undo or that changes scope. Do not guess about money, fees or
  settlement rules; ask or check the source.
- After each task, summarize what changed, how to verify it, and anything the user must do next.
- If a setup step changes (new tool, new command, new file), say so, so the setup how-to can be updated.
- Done means: tests pass, ruff and pre-commit are clean, and `docs/SPEC.md` or `docs/decisions.md` are updated if behavior or decisions changed.
- The app shows a disclaimer: it is not financial advice.
