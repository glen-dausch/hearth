# CLAUDE.md: standing instructions for Claude Code in this repo

Hearth: a local Windows app that helps one person make better-informed calls on Kalshi sports markets and tracks
whether those calls work out. Read `docs/SPEC.md` (what to build) and `docs/decisions.md` (what is decided) before
starting any feature. If they conflict with a request, say so and ask before proceeding.

## Hard rules (never break these)
- Never place, simulate placing, or prepare real orders or trades. v1 has no Kalshi account keys at all.
- Never read, print, log, copy or commit `.env`, anything in `secrets/`, or any `*.pem` or `*.key` file.
- Never commit or push to `qc` or `main`. Never merge pull requests. Never force-push, rewrite history, or use `--no-verify`.
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

## Git workflow
- Branches: `main` (production), `qc` (testing), `dev` (daily work). Work on `dev`, or on a short-lived
  `feature/<short-name>` branch created from `dev` for a single problem.
- Commit small and often with clear messages. Before each commit, tests and pre-commit must pass.
- Moving work up (`dev` to `qc` to `main`) is done by the user through pull requests. Tell the user when a branch is ready.

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
- The user is comfortable running commands but is not a professional developer. Explain what you are doing in
  plain language, in small steps, and give PowerShell commands for anything the user must run.
- Ask before making a decision that is hard to undo or that changes scope. Do not guess about money, fees or
  settlement rules; ask or check the source.
- After each task, summarize what changed, how to verify it, and anything the user must do next.
- If a setup step changes (new tool, new command, new file), say so, so the setup how-to can be updated.
- Done means: tests pass, ruff and pre-commit are clean, and `docs/SPEC.md` or `docs/decisions.md` are updated if behavior or decisions changed.
- The app shows a disclaimer: it is not financial advice.
