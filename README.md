# Japan Parking Advisor

**Parking in Japan has three traps Google Maps never mentions: a height bar your car can't clear, a price that triples if you guess wrong, and a "full" sign you only see after you've driven there.**

Apps like NAVITIME and the タイムズ apps will help — if you pay the subscription, and if you're willing to read a list and do the filtering yourself. This gives you the **decision** instead: where to park, filtered for *your* car, costed for *this* trip, with the "can it even get in?" check done first — running inside the ChatGPT / Claude / Gemini you already use. **Nearly free.**

> 🌏 中文: [README.zh.md](README.zh.md) ・ 日本語: [README.ja.md](README.ja.md)

## Why it exists

You're in an unfamiliar Japanese city. Google Maps says you've arrived — but where do you actually park? The cheap coin lot turns out to be a 1.55m mechanical tower your car can't clear. The one you pick has no daily cap and bills you ¥4,000 for three hours. And the good lot? You find out it's full only after you've driven there.

Google Maps shows you parking lots. It doesn't tell you:
- **Can my car physically get in?** Height limits and mechanical-lot traps (a tower lot capped at 1.5m rejects most SUVs; some lots only fit you on the self-park floor).
- **Which is cheaper for *my* stay?** It surfaces the cost drivers — hourly vs daily-max vs merchant discounts — to compare on; it does *not* compute a guaranteed net-cheapest price (discounts vary by receipt/store/day, and getting that math confidently wrong is worse than not doing it).
- **What do I do when I get there and it's full?** — the #1 real failure. That's why this tool always gives **parallel alternatives**, not one answer. (It does not check live vacancy — alternatives are route options, not availability guarantees.)

Scope: **Japan-specific** (sources, search queries, lot types like 自走式/機械式, and discount conventions are all Japanese). Parking is a strongly regional problem — this is not a one-size-fits-the-world tool. The underlying mechanics could be re-pointed at another country, but as shipped it assumes Japan; elsewhere is unsupported.

## Not another parking app

| | NAVITIME / タイムズ-style apps | Japan Parking Advisor |
|---|---|---|
| What you get | a searchable database — you filter it | a decision — filtered for your car, costed for your trip |
| Can your car get in? | you check each lot's height yourself | filtered out up front; an unpublished height is flagged, not guessed |
| What it costs you | subscription / premium tier | runs in the AI you already pay for — ~free |
| When it's full | — | parallel backups, so you don't circle the block |

And it tells you **when it doesn't know** — an unconfirmed height limit is flagged, never guessed — the opposite of an AI that answers confidently and wrong.

## Two layers — which to use

**Quick rule: not technical / just want an answer → L2. You run an AI agent (Claude Code etc.) and want verified, click-straight-to-the-lot links → L1.**

| Layer | What it is | Link quality | Needs | Use when |
|---|---|---|---|---|
| **L1 — skill** (`skill/`) | A full agent skill | **verified direct-to-lot links** (click → that exact lot's place card) — *only if you have a headless-browser stack*; otherwise it degrades to plain links and says so | a web-search API + a headless browser (see `skill/SETUP.md`); built for Claude-Code-style agents | you run an agent and want the best, pre-verified links |
| **L2 — prompt** (`prompt/`) | A copy-paste prompt | plain Maps links — **cannot verify the link points at the right lot** (same-name-chain / rental disambiguation is L1-only, so you open each and confirm before driving) | any LLM with live web search | you just want a quick answer, zero setup |

**Most people who aren't running an agent want L2.** It does the same search + car-filter + honest reasoning — the tradeoff is you self-verify each link (open it, confirm it's the right lot) before you drive.

### The design (one engine, two shells)
L1 and L2 share one engine — the same data/filter/present model, the same honesty rules, the same ranking. Only the runtime differs (an agent with a browser → full; a chat LLM → downgraded). The shared rules both layers must satisfy are written down in [`skill/ENGINE-INVARIANTS.md`](skill/ENGINE-INVARIANTS.md).

## Install

**L1 (skill):** copy the `skill/` directory into your agent's skills folder, then follow [`skill/SETUP.md`](skill/SETUP.md) for the three dependencies (search API / headless browser / fetcher). Without a headless browser it still runs — links just degrade to plain Maps + a notice.

**L2 (prompt):** open [`prompt/PROMPT.md`](prompt/PROMPT.md) (or [`.zh`](prompt/PROMPT.zh.md) / [`.ja`](prompt/PROMPT.ja.md)), copy everything below the line, paste it into any LLM with web search, then tell it where you're driving and what car you drive.

## How it handles data honesty

Exception-triggered: it does **not** recite a source/date/confidence for every line (that's noise). It speaks up only when something's genuinely off. The **one hard rule**: an unknown height/width limit is *always* stated — "can my car enter" is safety, not noise — and such a lot is never the top pick.

## A note on speed (cold start)

This OSS version is **live-search-first** — it ships a small demo dataset, **not** a pre-built regional cache. So the first query for a new area is slower and a bit less certain than a privately-cached setup would be. You can build your own local cache over time (see the demo dataset shape in `skill/references/parking-data.md`).

## Known differences across LLMs

The three big LLMs behave differently on the L2 prompt (web search defaults, link formatting). No equivalence is promised — see [`KNOWN-DIFFERENCES.md`](KNOWN-DIFFERENCES.md).

## License

MIT — see [LICENSE](LICENSE).
