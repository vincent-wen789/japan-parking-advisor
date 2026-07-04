# SETUP — running the L1 skill at full strength

## L1 vs L2 — which do you want?

- **L1 (this skill)** needs the dependencies below to produce its best output: **WYSIWYG place-card links** (click → the lot's Google card, with same-name-chain / car-rental traps filtered out). It's built **for browse-capable agents** (Claude Code and similar) — i.e. an agent that can run a headless browser and read pages back.
- **No setup / not an agent?** Use the **L2 prompt** in `../prompt/` instead — paste it into any LLM with web search. You get the same search + car-filter + honest reasoning, just plain Maps links (no place-card verification). Most people who aren't running an agent want L2.

If you install L1 but **lack a headless browser**, L1 still works — it just **degrades the link step** to honest Maps search links (viewport-anchored / `api=1` query — see `references/search-sources.md` "No-browser link fallback"; it never invents CID numbers) and says so in its output (it won't pretend the links are verified). At that point L2 is the simpler choice.

## The three dependencies

### 1. Search backend (required) — discover candidates
A web-search API the skill calls to find nearby parking. **Recommended: [Exa](https://exa.ai)** (has a free tier).
- Get a key at exa.ai → set it in your environment: `export EXA_API_KEY=...`
- Any web-search-capable tool your agent already has also works.
- Example query shapes (Japanese works best for JP destinations):
  - `"<station> 周辺 駐車場"`  (parking near a station)
  - `"<facility> 駐車場 料金 高さ"`  (a facility's parking rate + height)
  - `"<area> 無料駐車場"`  (free parking in an area)

### 2. Headless browser (required only for WYSIWYG CID links)
A headless-browser CLI/tool that can: **open a URL → wait → read the current URL → dump the page DOM/markdown.** A Playwright- or Puppeteer-based tool works; so does a browser MCP your agent already has. (It must run the page's JavaScript and report the *current* URL — the Maps place URL is produced client-side, so a plain HTTP fetcher never sees it, even one that follows redirects.)
- This is what builds the CID place-card link and runs the ~150m same-name-lot disambiguation (see `references/search-sources.md`).
- **Without it:** the skill degrades to plain Google Maps links + a downgrade notice (it does not silently ship unverified links). See `SKILL.md` → "Graceful degrade."
- (A bundled reference headless script is **not** shipped in this version — if there's demand, it's a planned follow-up. For now, wire your agent's own browser tool.)
- **Known fragilities (read before relying on the CID step):** the build flow scrapes an un-contracted Google URL shape. It can break when Google changes the URL format, serves a consent page, or rate-limits automated visits. The designed failure mode is loud, not wrong: mid-run breakage degrades to the fallback link forms + the downgrade notice — it never fabricates a CID (see `references/search-sources.md`).

### 3. Web-page fetcher (required) — read official / aggregator pages
Anything that fetches a URL's content: `curl`, or your agent's fetch tool. Used to read official facility access pages, Times / NAVITIME detail pages, and municipal parking-guide systems for rates and height limits.

## Install check (confirm all three work)

1. **Search**: run a query like `"横浜駅 周辺 駐車場"` through your search backend → you should get back candidate lots / source pages.
2. **Headless browser**: open `https://www.google.com/maps/search/横浜ベイクォーター駐車場` → wait → read the current URL → you should see a `/maps/place/.../@lat,lng/...!1s0x...:0x...` URL (the ftid you turn into a CID).
3. **Fetcher**: fetch any official parking page (e.g. a Times detail page) → you should get its HTML/text with the rate and height fields.

If #2 fails or you skip it, L1 runs in degraded-link mode — that's expected, not an error.

## Cost envelope per query (so "free" stays a checkable claim)

Typically **~2–5 search-API calls + 3–6 page fetches**, plus **1–2 headless passes per candidate** when building CID links (see `references/search-sources.md` "Cost"). The spend is your own agent's API/token usage — the skill itself has no service fee.
