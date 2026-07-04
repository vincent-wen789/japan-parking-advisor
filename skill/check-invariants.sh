#!/bin/bash
# check-invariants.sh — cheap drift-guard for the hand-mirrored engine.
#
# The engine is one set of rules encoded by hand in the L1 skill (SKILL.md) and
# the L2 prompt (PROMPT.md + zh/ja mirrors), with no build step. This greps each
# load-bearing rule's cross-language anchor (a Japanese term / symbol / number
# that survives translation) across the shells and prints any shell that's
# missing it — a first-order drift alarm. It does NOT prove full semantic
# equivalence; after it passes, still eyeball the rules by hand.
#
# NOT CI — a runnable checklist. Run after editing any engine rule.
# Exit 0 = all anchors consistent; exit 1 = a shell is missing/leaked one.
cd "$(dirname "$0")/.." || exit 2
FAIL=0

# present: anchor MUST appear in every listed file
need() {
  local anchor="$1"; shift
  local miss=""
  for f in "$@"; do grep -qF -- "$anchor" "$f" 2>/dev/null || miss="$miss $f"; done
  if [ -n "$miss" ]; then printf '❌ [%s] missing in:%s\n' "$anchor" "$miss"; FAIL=1
  else printf '✓ [%s] in %d shells\n' "$anchor" "$#"; fi
}

# forbid: anchor must NOT appear in any listed file (a fixed terminology leak)
forbid() {
  local anchor="$1"; shift
  local hit=""
  for f in "$@"; do grep -qF -- "$anchor" "$f" 2>/dev/null && hit="$hit $f"; done
  if [ -n "$hit" ]; then printf '❌ forbid [%s] leaked into:%s\n' "$anchor" "$hit"; FAIL=1
  else printf '✓ forbid [%s] clean in %d shells\n' "$anchor" "$#"; fi
}

PROMPTS="prompt/PROMPT.md prompt/PROMPT.zh.md prompt/PROMPT.ja.md"

# inv 10 — hotel/overnight scenario, anchored on its overnight-rate term
need "夜間最大"          skill/SKILL.md $PROMPTS skill/ENGINE-INVARIANTS.md skill/references/search-sources.md
# inv 2 — rental/model-unknown fallback, anchored on the ±10cm band
need "10cm"             skill/SKILL.md $PROMPTS skill/ENGINE-INVARIANTS.md
# inv 11/12 — roadside metered zone
need "パーキングメーター"  skill/SKILL.md $PROMPTS skill/references/search-sources.md
# inv 13 — CID link form (the no-fabrication rule lives with it)
need "cid="             skill/SKILL.md $PROMPTS skill/references/search-sources.md
# terminology — 計費 (Chinese, not Japanese) must stay out of shell bodies (2026-07-04 fix)
forbid "計費"           skill/SKILL.md $PROMPTS skill/references/search-sources.md skill/references/parking-data.md

if [ $FAIL -eq 0 ]; then echo "— all anchors consistent."; else echo "— DRIFT: fix the missing/leaked anchors above."; fi
exit $FAIL
