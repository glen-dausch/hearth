# Hearth: Product Spec (v1)

Status: draft 0.1, 2026-11-11. Owner: Glen. Decisions live in `docs/decisions.md`; this file says what to build.
Hearth is a local Windows app. It is not financial advice and it does not place real trades in v1.

## 1. Purpose

Help one person make smarter, better-informed calls on Kalshi sports markets and learn, with evidence, whether those
calls (and the app's predictions) are any good. It is built so other people can use it later.

## 2. What v1 does

1. Reads public Kalshi market data and saves price history from the first day it runs.
2. Shows two independent predictions for each market, side by side, with a plain-language suggestion.
3. Lets the user pick a side on any market and tracks the pick (pretend money only) until the market settles.
4. Reports how picks and each predictor performed.
5. Replay mode: go back up to one week, see what the app would have predicted, pick, then reveal the result.

## 3. What v1 does not do

Real trades or order placement, Kalshi account keys of any kind, Telegram or other alerts, an installer, other market
categories (weather, crypto, economics), mobile, multiple users.

## 4. Words used in this spec

- **Market:** one yes/no question on Kalshi (for example, "Will the Lakers win tonight?").
- **Contract price:** what a YES share costs, in cents (1 to 99). A YES share pays 100 cents if the answer is Yes.
  A price of 62 means the market implies about a 62 percent chance.
- **Prediction:** a probability (0 to 1) that a market resolves YES, produced by one predictor at one moment.
- **Edge:** predicted probability minus market-implied probability. A positive edge means the predictor thinks YES is underpriced.
- **Suggestion:** a plain-language recommendation built from predictions and edge. The user always decides.
- **Pick:** the user's chosen side on a market, with the price at the time and a pretend stake.
- **As-of time:** the moment a piece of data was observed. Every stored observation has one.

## 5. Leagues and bet types

- Leagues, in order: NBA, then NFL, then NHL. Each league is a plug-in on one shared engine (schedule, teams,
  ratings, market mapping). The engine knows nothing about a specific league.
- Bet types, in order: game winners first, then point spreads, then totals (over/under). All three are in v1; the
  order is for building and learning.

## 6. Data sources (verify each before depending on it)

| Source | Used for | Key needed | To verify |
| --- | --- | --- | --- |
| Kalshi public market data | Markets, prices, results, price history | No | Rate limits; how spread and total markets are named; history depth |
| Sportsbook odds (The Odds API) | Baseline predictor input | Yes (free tier) | Free-tier request limits; whether historical odds need a paid plan |
| ESPN public scoreboard and schedule | Schedules, scores, results | No | Unofficial, so it may change without notice |
| NBA, NHL and NFL stats packages or APIs | Team ratings and context | No | Terms and current availability per league |

Rules: respect rate limits, cache responses, and record the source and as-of time of everything saved.

## 7. Predictions

Two predictors run on every market and are saved and scored separately.

- **Predictor A (baseline):** removes the sportsbooks' built-in margin from their odds to get a consensus probability,
  then blends in a simple team-rating estimate (for example an Elo-style rating).
- **Predictor B (AI model):** a language model, local through Ollama first, given the same facts and asked for a
  probability and a short written reason.

Every prediction stores: market, predictor id and version, probability, as-of time, the inputs used, and the
written reason (for B). Neither predictor ever sees information from after its as-of time.

**Scoreboard** (per predictor, per league, per bet type): hit rate, a calibration score (Brier score), and pretend
profit if the suggestion had been followed. Each is also compared with simply trusting the market price.

## 8. Suggestions

Suggestion = edge from each predictor, shown together, with a plain explanation. Fees and rounding are included
once Kalshi's fee rules are confirmed (open question).

Adaptive behavior, in stages:
1. v1 start: next to each suggestion, show how the user's own past picks did for the same league and bet type, and
   how each predictor did.
2. Later: let those results gradually shift how much weight each predictor gets. Small samples must not swing it.

## 9. Picks and tracking

- The user opens a market, chooses YES or NO, and may enter their own probability.
- Default pretend stake: 10 dollars (changeable in settings).
- A pick stores the price at that moment and moves open, then won, lost or void when Kalshi settles the market.
- Several picks are open at all times; the pick list is always visible.
- Pretend profit uses the saved price, the stake and (when known) Kalshi's fees.

## 10. Browse, search and filter

- Browse all markets the app has seen; search by team or text.
- v1 filters: league, bet type, game date, open or settled, has a pick. More later.

## 11. Replay mode

1. Choose a past date, up to seven days back.
2. Hearth shows the markets that were open then, using data saved or fetched for that time.
3. It shows each predictor's prediction and the suggestion, using only data observed before the chosen time.
4. The user picks.
5. Hearth reveals the real result and updates a replay scoreboard, kept separate from live results.

Rules: no peeking (as-of queries only); old data must exist (Kalshi candlesticks and trades, odds history may be
unavailable, in which case replay uses Kalshi history plus free stats); a week of games proves the plumbing works,
not that predictions are skilled. Replay may be removed later.

## 12. Screens (simple dashboard)

Home (open picks and scoreboard), Markets (browse, search, filter), Market detail (price history, both
predictions, suggestion, make a pick), My picks, Replay, Status (data freshness and errors). The technology for the
dashboard is an open question; a local web app is the likely long-term direction.

## 13. Data and storage

SQLite in WAL mode, one background collector as the only writer, the dashboard read-only. Append-only observations
with as-of timestamps in UTC, prices in whole cents. The database file lives in `%LOCALAPPDATA%\Hearth\`. Conceptual
tables: leagues, teams, games, markets, market_snapshots, odds_snapshots, predictions, picks, results, scores.
Details go in `docs/ARCHITECTURE.md`.

## 14. Non-functional requirements

- Windows only. Everything runs locally.
- The dashboard must stay responsive: it reads saved data, and all network and AI work happens in the background.
- No secrets in the repository or in logs.
- The UI shows the disclaimer: not financial advice.

## 15. Success test (provisional)

For every pick and prediction, record the prediction, the market price at that moment and the outcome, then show hit
rate and pretend profit (as if 10 dollars were bet each time). Refine as we learn more about Kalshi.

## 16. Build order (the roadmap will detail it)

1. Kalshi reader and snapshot storage for NBA winners.
2. Results and settlement.
3. Predictor A and the scoreboard.
4. Picks and tracking.
5. Dashboard.
6. Predictor B (AI model) shown beside A.
7. Replay mode.
8. NFL and NHL.
9. Spreads and totals.

## 17. Open questions

- Kalshi rate limits and the fee schedule.
- Whether historical sportsbook odds are available on the free tier.
- How Kalshi names spread and total markets.
- Whether sports markets are available at the user's location.
- Dashboard technology.
- The details of the rating model and the adaptive weighting.
