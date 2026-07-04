# Parking Data — demo dataset (schema + worked examples)

> This is a **demo dataset, not a live cache.** It shows the data-layer schema and a few fully-worked lots so you can see the shape of a record. **Everywhere else = live search** (see `../SKILL.md` search flow + `search-sources.md`); records you scrape get written in the shape below.
>
> **How to edit**: each lot is one `###` block — change a line, don't touch SKILL.md logic. Rates/discounts change maybe twice a year; low-frequency maintenance.
> **Maintenance**: each lot carries `confirmed-date` + `source` (official-page URL, for re-checking). Re-verify every 6–12 months; the output always carries a "data as of" note to make staleness explicit.
> **"unconfirmed"**: a field that wasn't on the fetched page — not invented. Tell the user that field is unconfirmed; don't fill in a value for it.
> **No hardcoded car**: the fit verdict is NOT a stored field — it's computed by the filter layer at runtime from the lot's height/width limit vs the user's car. The `# fit example` lines below are illustrative only (showing how the filter would treat a typical ~1.65m SUV), not data.

## Data-layer schema (fill new records like this during live search; pick a profile by scenario)

**City paid profile** (most city-center / mall lots):
area · facility · type (self-park / mechanical) · hourly rate · daily max (or "none") · merchant discount · height & width limit · Google Maps · confirmed-date · source
（`confidence` is **not** a stored field — it's derived at read time; see the convention below.）

**Suburban free profile** (sightseeing / suburb / roadside station):
free? · time limit (e.g. 2h free / cap) · type (flat / roadside-station / convenience-store) · RV-OK · restroom? · location · Google Maps · confirmed-date · source
（`confidence` is **not** a stored field — derived; see convention.）

**confidence convention**: confidence is a **derived read, NOT a separately stored row** — compute it at read time from the three fields you DO store (`source` authority + `confirmed-date` freshness + any field marked "unconfirmed"). Don't write a literal `confidence:` line of your own and then trust it; re-derive from those three so the stored value and the judgment can never drift. confidence = **source authority × freshness** — don't default to high. (The `# confidence (derived)` comment lines in the worked examples below show what that derivation reads as for each row — they are comments, not stored fields; new records you write should carry only `source` + `confirmed-date` + any "unconfirmed" markers.)
> - Source: confirmed entirely by an **official page** = high; **third-party aggregator only** (Times / NAVITIME / parking aggregators) = medium; any second-hand / inferred field → **that field** drops to low (official source doesn't publish height/width yet you inferred "fits" → must label unconfirmed + "conditional," never high).
> - Freshness: `confirmed-date` > 6 months → drop one tier even for an official source; output prompts a re-check / treat as cache miss.

**Roadside time-limited profile** (パーキングメーター / パーキングチケット / 時間制限駐車区間 — legal paid on-street zones; **a different data TYPE from a garage, with a fundamentally different risk profile**):
area · 設置区間 (street / chōme) · type (メーター coin / チケット ticket-issue) · rate (standard 60 min ¥300 — **the on-site sign is authoritative**) · time limit (**legal cap, usually 60 min; over-time = 駐車違反, NOT pay-more-to-extend**) · usable hours (as posted; outside the band = no-parking) · enforcement / tow risk (high) · availability (**no reservation, no real-time vacancy — confirm on site**) · height (open-air — basically irrelevant) · normal-vehicle zone? (most cars OK; oversize = check) · Google Maps (navigable area-search link, see below) · confirmed-date · source (**prefectural police / public-safety-commission 設置場所 page — engine-internal only**)
> **RED LINE (safety + legal)**: only recommend a **legal metered zone inside an official 設置区間**; any "looks parkable" **unmarked roadside is NOT a candidate** (= 駐車違反 / レッカー tow). **Short stops only (≤ the time limit) — never present it as a long-stay option**; in the output it goes in its **own line, never mixed into the garage ranking** (cures "I thought I could park there a while"). 設置場所 confirmed by the official police page = high confidence, but **per-spot rate / hours / vacancy must be confirmed on the on-site sign** (no real-time data).
> **User link is NOT the police page** (that's a table, not navigable). The user link is a navigable Google area-search: `https://www.google.com/maps/search/パーキングメーター/@<destination lat>,<lng>,17z` (opens to the meter pins near the destination). The police/public-safety 設置場所 page is the **engine-internal source** for "which street has a legal zone" — never hand it to the user.

## Worked examples — the full safety spectrum (yes / conditional / no)

The three lots below deliberately span the safety filter's three outcomes, so the demo teaches the **insight** (height/width is the killer feature vs Google Maps), not just the field names.

---

### 横浜ベイクォーター駐車場  — outcome: YES (clean self-park)
- area: Yokohama Station east side (Kinkocho, NE of the station)
- facility: 横浜ベイクォーター (commercial complex, underground self-park, 730 cars)
- type: self-park
- hourly rate: all-day 30 min ¥340 (incl. tax); 24:00–08:00 overnight ¥3,400
- daily max: none (Yokohama City parking guide states "no max")
- merchant discount: ベイクォーター ≥¥3,000 (1 store) = 1h free (each additional ¥3,000 = +1h voucher).
- height & width limit: 高さ2.20m / 幅1.95m / 長さ5.30m / 重量2.30t (3-number / RV / 1-box OK; in-lot bump)
- Google Maps: https://maps.google.com/?cid=13690509701379998062
- confirmed-date: 2026-05-30
- source: https://yokohama-parking-guidesystem.jp/result/1/10
- # confidence (derived): high (official guide system)
- note: self-park, no mechanical risk; the most reliable east-side choice. Open 8:00–23:00 (exit by 24:00).
- # fit example: a ~1.65m SUV (1.85m wide) → **yes** — self-park, 2.20m clearance and 1.95m width both clear with margin; RV explicitly OK.
- # link form: the Maps link above is a **CID place-card link** (`?cid=<CID>`) — the WYSIWYG form every candidate must use (opens straight to this lot's card). NOT a bare-coordinate or name-search query. How it's built: `search-sources.md` "WYSIWYG links."

---

### そごうパーキング館  — outcome: CONDITIONAL (self-park floor OK, mechanical floor won't fit)
- area: Yokohama Station east side
- facility: そごう横浜店 (own multi-storey lot, 560 cars, largest in the Yokohama-station area)
- type: self-park (flat zone) + mechanical (tower zone)
- hourly rate: 30 min ¥340 (incl. tax)
- daily max: none (no daily-cap line on the official site; long stays accrue indefinitely)
- merchant discount: そごう purchase ≥¥3,000 incl. tax = 1.5h free (gift cards ≥¥5,000). Note: ベイクォーター spend can NOT be applied here (official).
- height & width limit: flat zone 2m10cm / **tower zone 1m50cm** (some sections 1m55/1m75/2m; "limit varies by parking position")
- Google Maps: https://maps.google.com/?cid=7086177179481059382
- confirmed-date: 2026-05-30
- source: https://www.sogo-seibu.jp/yokohama/access
- # confidence (derived): high (official access page)
- note: **the killer-feature case** — height varies by where you're parked. On arrival you MUST insist on the flat zone.
- # fit example: a ~1.65m SUV → **conditional** — the flat zone (2.10m) is fine, but if you're routed into the tower/mechanical zone (1.50m) the car **physically cannot enter.** Google Maps will not tell you this; the skill must. Never make a conditional lot the top pick without the warning.

---

### タイムズ新宿サンエービル  — outcome: NO (mechanical, hard height reject for an SUV)
- area: Shinjuku Station west side (Nishi-Shinjuku 1-22, very close to the west exit)
- facility: 新宿サンエービル attached coin parking (31 cars)
- type: mechanical (tower, attendant-guided)
- hourly rate: 20 min ¥200 (all day)
- daily max: 12h after entry max ¥1,500 (weekday/holiday same; repeats)
- merchant discount: partner-store / member discounts [specific stores unconfirmed]. The ¥1,500/12h cap is already cheap; good for long stays.
- height & width limit: 全高1.5m / 全幅1.85m / 全長5.05m / 重量1.6t (entry/exit 07:30–21:00)
- Google Maps: https://maps.google.com/?cid=12164895901886786198
- confirmed-date: 2026-05-30
- source: https://times-info.net/P13-tokyo/C104/park-detail-BUK0037632/
- # confidence (derived): medium (aggregator detail page)
- note: cheap, but an SUV has no chance — a textbook Shinjuku mechanical lot that excludes mid-size SUVs. Mechanical, 07:30–21:00 only (no overnight exit).
- # fit example: a ~1.65m SUV → **no** — mechanical full-height 1.5m < 1.65m, hard reject (1.85m width is also already at the edge). The filter drops this lot; it must never appear as a top pick for a tall car.

---

### 〔roadside zone〕Yokohama Station west-side パーキングメーター/チケット  — outcome: SHORT-STAY ONLY (not a garage — different data type)
- profile: roadside time-limited (see "Roadside time-limited profile" above) — **do not rank this alongside the garages**; it only appears as a separate "short-stay option" line when the user signals a short stop.
- area: Yokohama Station west exit (Nishi-ku Kitasaiwai / Minamisaiwai etc.)
- type: パーキングチケット発給機 (ticket-issue; central Yokohama on-street is mostly ticket-issue, not coin meters)
- rate: standard 60 min ¥300 — **on-site sign is authoritative**
- time limit: **60 min, legal cap** (道交法 時間制限駐車区間; over-time = 駐車違反 / 取締, NOT pay-more-to-extend)
- usable hours: only as posted on the sign (outside the band = no-parking)
- enforcement / tow risk: HIGH (over-time / outside-zone / outside-hours = ticketed)
- availability: **no reservation, no real-time vacancy — confirm on site**
- height: open-air — basically irrelevant
- normal-vehicle zone: yes (most cars OK; oversize = check)
- Google Maps: https://www.google.com/maps/search/パーキングメーター/@35.4665,139.6212,17z (area search → meter pins near the west exit; a roadside zone is **not a single lot** — opens to nearby meter pins, navigable)
- confirmed-date: 2026-06-03
- source: prefectural police / public-safety-commission 設置場所 page (engine-internal — **NOT a user link**)
- # confidence (derived): high for the zone existing (official 設置場所); rate / hours / vacancy on-site only
- note: **short stops (≤60 min) only** — shopping / long stays go to the garages above. Cheap & close but high over-time risk; only the posted metered zone is legal, unmarked roadside = violation. After opening the link, **read the チケット発給機 / メーター pin on the map; list entries with a floor address (○○ビル N階) are in-building coin lots, not roadside — don't pick those.**
- # filter example: the open-air zone has no height gate, so the car filter is a near-pass for any normal vehicle — but the **scenario filter** is what matters: this row is suppressed entirely unless the duration is a short stop. A long-stay / unspecified-duration request must NOT surface it.
