# Decisions so far

Source of truth for what we have decided. Add a dated line whenever something changes.

## Product
- **Name:** Hearth. Slogan: "Stay warm. Think clearly." (slogan may change)
- **Goal:** A local app that helps you make smarter, better-informed calls on prediction markets: it lines up your
  picks, shows how likely each outcome is, and tracks whether your thinking pays off.
- **Audience:** The owner for now, built so others can use it later (distribution in mind at every step).
- **Platform:** Windows only for v1.
- **Version 1 scope:** Sports markets on Kalshi: NBA first, then NFL and NHL, as one shared engine with a plug-in
  per league. Pick or set up bets and track them without placing real trades; several open at all times. Save
  Kalshi price history from day one. No Kalshi trading keys (public market data needs none).
- **Bet types (v1 target):** game winners, point spreads and totals (over/under). Build winners first, then the other two.
- **Predictions:** Two separate methods run side by side and are stored and scored separately, so we can later see
  which works better: (A) a baseline from sportsbook odds plus team ratings, (B) an AI model (local Ollama first).
- **Suggestions:** The app suggests; the user decides. Suggestions adapt over time to the kinds of bets the user has made.
- **Browsing:** Browse, search and filter markets. Start with simple filters and extend later.
- **Screen:** A simple dashboard in v1. A local web app is the likely long-term direction.
- **Replay (test mode):** Go back up to one week, see the app's prediction and suggestion as of then, make a pick,
  then reveal the real result. Rules: no peeking at later information; old data must exist; a week proves plumbing,
  not skill. May be removed later.
- **Success test (provisional):** For each pick record prediction, market price and outcome; show hit rate and
  pretend profit. Revise as understanding of Kalshi grows.
- **Risk rules:** Deferred until the app runs and the terms are visible.
- **Database:** SQLite in WAL mode, one background writer, dashboard read-only, append-only observations with as-of
  timestamps, SQLAlchemy and Alembic so a later move to another database is possible. Rules are in `CLAUDE.md`.

## Process
- **Branches:** `main` (production), `qc` (testing), `dev` (daily work). Short-lived branches for single problems
  merge into `dev`.
- **Pull requests:** Required for merges into `qc` and `main` (GitHub ruleset). The CI workflow runs the pre-commit
  checks and the tests on every pull request into `dev`, `qc` or `main`.

## Revisit later
- Risk rules (bankroll, per-trade cap, kill switch).
- Local web app instead of the simple dashboard.
- Which bet types to build first, and how deep to go on spreads and totals.
- Filter options for browsing and searching.
- Success test, once we understand Kalshi better.
- Database: revisit only if concurrency, data size or a multi-user need appears.
- Replay mode: keep or remove after testing.
- Weekly automatic pre-commit update (pull request).
- Telegram alerts, the installer (.exe) and the role of AI beyond the second prediction method.
