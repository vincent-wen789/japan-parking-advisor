# Known Differences across LLMs (L2 prompt)

This tool does **not** promise that ChatGPT, Claude, and Gemini behave identically on the L2 prompt. They differ in whether web search is on by default, how they format links, and how reliably they honor the "ask for the car first" and "downgrade notice" instructions. This table tracks observed differences — it's a living document, not a guarantee.

| LLM (version tested) | Live web search | Resolves a Maps share/short link? | Link format returned | Downgrade notice shown? | Car handling |
|---|---|---|---|---|---|
| **ChatGPT** (5.5 Thinking) | Yes — cited 食べログ / 三井のリパーク / Times | **Yes** — resolved `maps.app.goo.gl/...` straight to the venue | resolved "Google Maps" place hyperlinks | Yes (in 中文) | Confirmed the car (model: Harrier) up front, derived its dimensions, and flagged the width as tight (~4.5cm to the 1.9m limit). |
| **Gemini** (2.5 Pro) | Yes | **No** — couldn't open the short link; needed the place name + address | `?api=1&query=<address>` (lands near the lot, not a verified card) | Yes — printed the "DOWNGRADE NOTICE" label verbatim (in 中文) | Used the car the user supplied; flagged the width as tight. |
| **Claude** | Yes, when enabled in the client | not tested live (filter logic verified offline) | plain Google Maps links | Yes (offline test) | Behavioral test: no car → asked for height; a 2.3m car was excluded from all lots; a conditional-entry lot was flagged. |

## Smoke-test log

- **ChatGPT 5.5 Thinking** (2026-05-31, real web-UI paste-test) — destination given as a `maps.app.goo.gl` short link (中山菜館, 横浜市神奈川区松本町). Confirmed the car (model: Harrier) + destination, resolved the link itself, searched the web (三井のリパーク / Times / 食べログ cited), returned **4 parallel candidates** each with rate + capacity + height & width, flagged the Harrier's width tight (~4.5cm to the 1.9m limit), noted these are 自走式/平地 not 1.55m mechanical, showed the downgrade notice, answered in Chinese with JP lot names intact. **PASS** (the model-first car ask is the intended path — no fix needed).
- **Gemini 2.5 Pro** (2026-05-31, real web-UI paste-test) — **could not open the Maps short link**; resolved once given the place name + address. Then returned 3 parallel candidates, flagged width tight, excluded the mechanical option, printed the "DOWNGRADE NOTICE" verbatim, answered in Chinese. **PASS.** Quirk: no short-link redirect support → prompt updated with a "can't resolve the link? ask for name + address" fallback.
- **Claude** (2026-05-31, offline behavioral test) — ran PROMPT.md against 3 candidate lots under 3 car scenarios. Passed all: no-car → asked first; 2.3m car → excluded all 3 lots, no false top pick; 1.65m SUV → correct fit / conditional / excluded split; downgrade notice present. (Filter logic verified against the demo dataset, not a live web search.)

> **Takeaway (2026-05-31):** the prompt is **effective across all three with no per-provider forking** — the car path stays **force-ask** (ask for the car *model*, derive dimensions from it), and only one small universal robustness tweak was needed: a Maps-short-link → name+address fallback for models that can't follow the redirect (Gemini). Baked into all language versions.

## What to watch for when you test a new engine

1. **Does it actually search the web?** If not, the prompt tells it to stop — confirm it does, rather than answering from stale memory.
2. **Does it ask for your car's height before recommending?** This is the safety-critical step; a model that skips it is a problem.
3. **Does it show the downgrade notice?** The plain links are unverified — the notice must reach the user.
4. **Link quality** — does it return openable Maps links, or just text?
5. **Language** — does it answer in your language while keeping Japanese lot names intact?
