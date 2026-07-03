# Japan Parking Advisor

**Parking in Japan has three traps Google Maps never mentions: a height bar your car can't clear, a price that triples if you guess wrong, and a "full" sign you only see after you've driven there.**

Apps like NAVITIME and the タイムズ apps will help — if you pay for their premium tiers, and if you're willing to read a list and do the filtering yourself. This gives you the **decision** instead: where to park, filtered for *your* car, cost-compared for *this* trip, with the "can it even get in?" check done first — running inside the ChatGPT / Claude / Gemini you already use.

> 🌏 **日本語はこちら →** [README.ja.md](README.ja.md) ・ **中文版 →** [README.zh.md](README.zh.md)

## Start here (60 seconds, nothing to install)

1. **Tap/click this link to open the prompt: [`prompt/PROMPT.md`](prompt/PROMPT.md)** (also in [中文](prompt/PROMPT.zh.md) / [日本語](prompt/PROMPT.ja.md)).
2. Copy **everything below the `---` divider** — from "You are a parking decision assistant" down to the end.
3. Paste it into any AI chat that can **search the web** — most free tiers include web search these days. If yours can't search, the prompt says so and stops instead of guessing.
4. Tell it where you're driving and what car you drive: *"Kawagoe old town tomorrow, ~3 hours — Honda Freed."* Renting and don't know the model yet? Say the class — *"rental compact SUV, model unknown"* — it runs conservative (mechanical tower lots are excluded entirely until the real height is known) and tells you what to double-check at pickup.

**Paste once, reuse all trip:** just keep that chat around and send new destinations into it (works on any tier) — or, if your plan supports it, save it as a custom GPT / Project / Gem.

**Cost: the prompt is free.** No account, no API key, no install — your existing AI chat does the searching. Expect an answer to take **a minute or two of live searching** (paid tiers tend to search deeper); it's checking real pages, not reciting a stale database.

(There's also a full agent skill for people who run AI agents — it adds pre-verified place-card links on top of the same engine. That's the `skill/` directory, explained under "Two layers" below. If "AI agent" means nothing to you, the copy-paste prompt above is the whole product.)

## What an answer looks like

Built from the repo's own verified demo data (Yokohama, confirmed 2026-05) — same shape in your language, whichever layer you run:

> **You:** Driving to そごう横浜店 tomorrow, shopping ~3 hours. Car: Honda Freed.
>
> **AI:** Near Yokohama Station east side, parked ~3h, your Freed (≈1.71m tall — worth confirming on the 車検証 if a lot is borderline): both picks below clear it, but watch the そごう tower zone.
>
> **横浜ベイクォーター駐車場** (top pick) — self-park, 730 cars, ¥340/30min; a ¥3,000 store receipt = 1h free. 2.20m clearance, plenty of room.
> https://maps.google.com/?cid=13690509701379998062
>
> **そごうパーキング館** (right at the store) — ¥340/30min, そごう receipt ≥¥3,000 = 1.5h free. **Conditional: the flat zone (2.10m) fits; the tower zone is capped at 1.50m and your car won't go in — ask for the flat zone at the gate (the phrase to say or show: 「平面でお願いします」 = "flat zone, please").**
> https://maps.google.com/?cid=7086177179481059382
>
> *(…plus 1–2 more parallel backups in a real answer — if the top pick turns out full, you just drive to the next one; that's the designed path, not a failure.)*
>
> Both self-park; rates from official pages — the on-site board is authoritative.

That そごう line is the whole point: Google Maps shows both lots, but not that one of them only fits your car on certain floors.

## Why it exists

You're in an unfamiliar Japanese city. Google Maps says you've arrived — but where do you actually park? The cheap coin lot turns out to be a 1.55m mechanical tower your car can't clear. The one you pick has no daily cap and bills you ¥4,000 for three hours. And the good lot? You find out it's full only after you've driven there.

Google Maps shows you parking lots. It doesn't tell you:
- **Can my car physically get in?** Height limits and mechanical-lot traps (a tower lot capped at 1.55m rejects most SUVs; some lots only fit you on the self-park floor).
- **Which is cheaper for *my* stay?** It surfaces the cost drivers — hourly vs daily-max vs merchant discounts — to compare on; it does *not* compute a guaranteed net-cheapest price (discounts vary by receipt/store/day, and getting that math confidently wrong is worse than not doing it).
- **What do I do when I get there and it's full?** — the #1 real failure. That's why this tool always gives **parallel alternatives**, not one answer. (It does not check live vacancy — alternatives are route options, not availability guarantees.)

Scope: **Japan-specific** (sources, search queries, lot types like 自走式 self-park / 機械式 mechanical, and discount conventions are all Japanese). Parking is a strongly regional problem — this is not a one-size-fits-the-world tool. The underlying mechanics could be re-pointed at another country, but as shipped it assumes Japan; elsewhere is unsupported.

## Not another parking app

| | NAVITIME / タイムズ-style apps | Japan Parking Advisor |
|---|---|---|
| What you get | a searchable database — you filter it | a decision — filtered for your car, cost-compared for your trip |
| Can your car get in? | you check each lot's height yourself | filtered out up front; an unpublished height is flagged, not guessed |
| What it costs you | subscription / premium tier | free — a prompt running in the AI chat you already use; no extra subscription |
| When it's full | — | parallel backups, so you don't circle the block |

And it tells you **when it doesn't know** — an unconfirmed height limit is flagged, never guessed — the opposite of an AI that answers confidently and wrong.

**"Can't I just ask ChatGPT raw?"** You can — and it will skip the height check unless you think to ask, hand you one answer with no backups, and happily produce a link that opens the wrong same-name lot. This prompt exists to force the checks raw prompting skips: car first, unknown heights flagged, parallel alternatives, links it isn't allowed to fabricate.

## Two layers — which to use

**Quick rule: not technical / just want an answer → L2 (the "Start here" steps above). You run an AI agent (Claude Code etc.) and want verified, click-straight-to-the-lot links → L1.**

| Layer | What it is | Link quality | Needs | Use when |
|---|---|---|---|---|
| **L1 — skill** (`skill/`) | A full agent skill | **verified direct-to-lot links** (click → that exact lot's place card) — *only if you have a headless-browser stack*; otherwise it degrades to plain links and says so | a web-search API + a headless browser + a page fetcher (see `skill/SETUP.md`); built for Claude-Code-style agents | you run an agent and want the best, pre-verified links |
| **L2 — prompt** (`prompt/`) | A copy-paste prompt | plain Maps links — **cannot verify the link points at the right lot** (same-name-chain / rental disambiguation is L1-only, so you open each and confirm before driving) | any LLM with live web search | you just want a quick answer, zero setup |

**Most people who aren't running an agent want L2.** It does the same search + car-filter + honest reasoning — the tradeoff is you self-verify each link (open it, check the pin sits by your destination) before you drive.

### The design (one engine, two shells)
L1 and L2 share one engine — the same data/filter/present model, the same honesty rules, the same ranking. Only the runtime differs (an agent with a browser → full; a chat LLM → downgraded). The shared rules both layers must satisfy are written down in [`skill/ENGINE-INVARIANTS.md`](skill/ENGINE-INVARIANTS.md).

## Install

**L1 (skill):** copy the `skill/` directory into your agent's skills folder (Claude Code: `~/.claude/skills/japan-parking-advisor/`), then follow [`skill/SETUP.md`](skill/SETUP.md) for the three dependencies (search API / headless browser / fetcher). Without a headless browser it still runs — links just degrade to plain Maps + a notice.

**L2 (prompt):** the "Start here" steps at the top of this page — open [`prompt/PROMPT.md`](prompt/PROMPT.md), copy everything below the `---` divider, paste into any LLM with web search, tell it where you're driving and what you drive.

## How it handles data honesty

Exception-triggered: it does **not** recite a source/date/confidence for every line (that's noise). It speaks up only when something's genuinely off. The **one hard rule**: an unknown height/width limit is *always* stated — "can my car enter" is safety, not noise — and such a lot is never the top pick.

## A note on speed (cold start)

This OSS version is **live-search-first** — it ships a small demo dataset, **not** a pre-built regional cache. So the first query for a new area is slower (expect a minute or two of searching) and a bit less certain than a privately-cached setup would be. You can build your own local cache over time (see the demo dataset shape in `skill/references/parking-data.md`).

## Known differences across LLMs

The three big LLMs behave differently on the L2 prompt (web search defaults, link formatting). No equivalence is promised — see [`KNOWN-DIFFERENCES.md`](KNOWN-DIFFERENCES.md) for the real paste-test log. All three passed; one quirk worth knowing up front: **Gemini can't follow Google Maps short links** — it will ask you for the place name + address instead.

## License

MIT — see [LICENSE](LICENSE).
