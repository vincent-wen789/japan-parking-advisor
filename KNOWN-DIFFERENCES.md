# Known Differences across LLMs (L2 prompt)

This tool does **not** promise that ChatGPT, Claude, and Gemini behave identically on the L2 prompt. They differ in whether web search is on by default, how they format links, and how reliably they honor the "ask for the car first" and "downgrade notice" instructions. This table tracks observed differences — it's a living document, not a guarantee.

| LLM | Web search by default? | Link format observed | Honors "ask for car height first"? | Notes / quirks |
|---|---|---|---|---|
| **Claude** | Yes, when web search is enabled in the client | plain Google Maps search / coordinate links | **Yes** — stopped and asked for car height when none was given | Correctly excluded a too-tall car from all lots, flagged a conditional-entry lot, and emitted the downgrade notice (behavioral test 2026-05-31) |
| **ChatGPT** | Yes (built-in browsing in recent versions) | _(to be filled — needs a real web-UI paste-test)_ | _(to be filled)_ | _(to be filled)_ |
| **Gemini** | Yes (built-in search) | _(to be filled — needs a real web-UI paste-test)_ | _(to be filled)_ | _(to be filled)_ |

## Smoke-test log

- **Claude** (2026-05-31) — ran PROMPT.md against 3 candidate lots under 3 car scenarios. Passed all: no-car → asked for height first; 2.3m car → excluded all 3 lots, no false top pick; 1.65m SUV → correct fit / conditional / excluded split; downgrade notice present. (Filter logic verified against the demo dataset, not a live web search.)
- **ChatGPT** — pending a real web-UI paste-test (one of the two ship gates)
- **Gemini** — pending a real web-UI paste-test (one of the two ship gates)

## What to watch for when you test a new engine

1. **Does it actually search the web?** If not, the prompt tells it to stop — confirm it does, rather than answering from stale memory.
2. **Does it ask for your car's height before recommending?** This is the safety-critical step; a model that skips it is a problem.
3. **Does it show the downgrade notice?** The plain links are unverified — the notice must reach the user.
4. **Link quality** — does it return openable Maps links, or just text?
5. **Language** — does it answer in your language while keeping Japanese lot names intact?
