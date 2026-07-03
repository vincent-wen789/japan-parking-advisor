# Changelog

User-visible behavior changes only. Engine-rule details and cross-check logs live in [`skill/ENGINE-INVARIANTS.md`](skill/ENGINE-INVARIANTS.md).

## 2026-07-04 — user-perspective hardening round

Driven by a 3-lens review (correctness / architecture / intent) + a 4-persona cold-read audit + a delta re-read. Behavior changes (both tiers):

- **Rental car / model unknown** is now an explicit, accepted path: give a vehicle class ("rental compact SUV, model unknown") → the engine anchors on the tallest model rented as that class in Japan, treats caps clearing it by <10cm as tight/conditional, excludes caps at/below it, and excludes mechanical lots until the real height is known.
- The engine now **states the car dimensions it's using** in one line, and points borderline cases at the 車検証 / rental paperwork.
- Unknown-model fallback asks for **height and width** (was: height only).
- **Default duration** when unstated: ~90–120 min (was "~1–2h", which overlapped the roadside legal cap and contradicted "the default is a non-short stay"). Overnight/all-day stays now prompt a lot-hours + overnight-max check.
- Roadside short-stay copy: "60-min legal cap" → "**the posted legal cap (usually 60 min)**" (some zones post 40 min).
- Conditional-entry output now hands the user the exact on-site phrase (e.g. 「平面でお願いします」).
- Docs: README rebuilt user-first (60-second quick start, sample answer built from the verified demo dataset, explicit free/cost line); "計費" terminology leak fixed (EN "metered zone" / JA 「時間制限駐車区間」); SETUP corrects the headless-browser requirement, adds known fragilities of the CID build flow and a per-query cost envelope; `parking-data.md` no longer lists `confidence` as a stored field (derived at read time).

## 2026-06-11 — link honesty hardening

- Link-form whitelist + **CID no-fabrication** red line in both tiers (invariant 13); no-browser fallback link forms documented.

## 2026-06-03 — roadside time-limited zones

- パーキングメーター/チケット added as a separate data type, short-stop-only, with the legal red line (invariants 11–12).

## 2026-05-31 — initial OSS release

- L1 skill + L2 prompt (en/zh/ja), demo dataset, 3-LLM paste-test log in `KNOWN-DIFFERENCES.md`.
