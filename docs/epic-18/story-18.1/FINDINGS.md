# Story 18.1 — Pre-flight: Name & Domain Availability Check

**Research Date:** 2026-02-27
**Epic:** 18 — App Rename: Gatherli → ?
**Issue:** #507

---

## Executive Summary

Two candidate names were researched: **"Gatherly"** and **"Gatherli"**.

| Name | Overall Risk | Verdict |
|------|-------------|---------|
| **Gatherly** | 🔴 HIGH | App store conflicts exist; `com.gatherly.*` taken; all major domains taken |
| **Gatherli** | 🟡 MEDIUM | No exact app conflicts; key domains available; main risk is phonetic trademark similarity to "Gatherly" |

**Recommendation: "Gatherli" is the safer pick**, provided trademark clearance is confirmed by a legal professional.
The project owner already owns `gatherly.ch`, which can serve as the deep linking domain for either name.

---

---

# Part 1 — "Gatherly" Research

---

## 1. Apple App Store — Gatherly

### Findings

Two distinct apps already named "Gatherly" are live on the iOS App Store:

| App | Developer | Category |
|-----|-----------|----------|
| **Gatherly Connect: Hangouts** (id6477335688) | ExponentialsSuccess | Social / Event discovery |
| **Gatherly Social** (id6461268313) | Gatherly Social Inc. | Social / Meal meetups |

- **Gatherly Connect** helps users find local hangouts, events, beach walks — closely adjacent to a sports social app.
- **Gatherly Social** matches users for group dinners; also a social coordination overlap.

### Risk: 🔴 HIGH
Apple's App Store review team flags name conflicts during submission. An existing developer could file an App Store dispute. The app name "Gatherly" alone (without a subtitle) will likely be rejected as a duplicate.

**Mitigation:** Submit as **"Gatherly Sports"** or **"Gatherly — Play Together"**.

---

## 2. Google Play Store — Gatherly

### Findings

Two Android apps use the "Gatherly" name:

| App | Package | Developer |
|-----|---------|-----------|
| **Gatherly — Your Social Spot** | `com.dc.gatherly` | ExponentialsSuccess |
| **Gatherly Social** | `com.gatherly.gatherly` | Gatherly Social Inc. |

The package namespace **`com.gatherly.*` is already claimed** by Gatherly Social Inc.

### Risk: 🔴 HIGH
`com.gatherly.app` cannot be used. Must use an alternative such as `ch.gatherly.app`.

---

## 3. USPTO Trademark — Gatherly

### Findings

Multiple commercial entities have operated under "Gatherly" since at least 2020:

| Entity | Type | Since |
|--------|------|-------|
| **Gatherly.io** (now GoLocal Virtual Events) | VC-backed B2B virtual events SaaS | 2020 |
| **Gatherly Social Inc.** | Legal entity, social app | ~2022 |
| **Gatherly Connect** | Consumer social app | ~2023 |

Even without a formal USPTO registration, **common law trademark rights** arise from commercial use. These entities likely hold enforceable claims in Classes 9, 41, and 42.

### Risk: 🔴 HIGH
⚠️ A formal USPTO TESS search is mandatory before proceeding.
Manual search: https://tmsearch.uspto.gov — Classes 9, 41, 42.

---

## 4. EUIPO Trademark — Gatherly

### Findings

- **Gatherly.io** domain is registered to a UK-based entity (Middlesex, GB), confirming European operations.
- No confirmed EU registration via automated search — manual verification required.

### Risk: 🟠 MEDIUM-HIGH
Manual search required: https://euipo.europa.eu/eSearch/ — Classes 9, 41, 42.

---

## 5. Domain Availability — Gatherly

| Domain | Status | Notes |
|--------|--------|-------|
| `gatherly.com` | ❌ TAKEN | Registered since 2007. UK-based registrant. |
| `gatherly.io` | ❌ TAKEN | Gatherly Virtual Events (now GoLocal). Registered 2020. |
| `gatherly.org` | ❌ TAKEN | Community events platform. |
| `gatherly.app` | ⚠️ LIKELY TAKEN | Associated with existing social app. WHOIS hidden (.app TLD). |
| **`gatherly.ch`** | ✅ **OWNED** | Already owned by project. Usable for deep linking. |

---

## 6. Social Media — Gatherly

### Instagram

| Handle | Status |
|--------|--------|
| `@gatherly_io` | TAKEN |
| `@gatherlyio` | TAKEN |
| `@joingatherly` | TAKEN (2,140 followers) |
| `@gogatherly` | TAKEN |
| `@gatherlyhk` | TAKEN |
| `@gatherly` | UNKNOWN — direct check required |

### X (Twitter)

| Handle | Status |
|--------|--------|
| `@gatherlyio` | TAKEN |
| `@gatherly` | UNKNOWN — direct check required |

### Risk: 🔴 HIGH — Heavy brand occupancy around the "Gatherly" namespace.

---

## 7. Gatherly Ecosystem Map

| Entity | Type |
|--------|------|
| Gatherly.io / GoLocal Virtual Events | B2B Virtual Events SaaS (VC-backed, acquired 2024) |
| Gatherly Connect: Hangouts | iOS/Android consumer social app |
| Gatherly Social Inc. | Meal-matching social app (iOS + Android) |
| gatherly.org | Community events platform |
| @joingatherly (Instagram) | Social community, 2,140 followers |
| @gatherlyio (X) | Virtual events company |

---

---

# Part 2 — "Gatherli" Research

---

## 1. Apple App Store — Gatherli

### Findings

**No app named "Gatherli" exists** on the iOS App Store. The nearest results are the "Gatherly" apps documented in Part 1, which appear as near-matches in search but are not name conflicts for a submission under "Gatherli".

### Risk: 🟡 MEDIUM
No exact name conflict. However, phonetic proximity to "Gatherly" social apps (same category) may create consumer confusion — and Apple's review team considers this. A subtitle (e.g., "Gatherli Sports") further differentiates.

---

## 2. Google Play Store — Gatherli

### Findings

**No app named "Gatherli" exists** on Google Play. The `com.gatherli.*` package namespace appears unclaimed.

### Risk: 🟡 MEDIUM
No exact conflict. Package ID `ch.gatherli.app` is freely available.

---

## 3. USPTO Trademark — Gatherli

### Findings

- No confirmed trademark filing for "Gatherli" found in any indexed source.
- One personal/student developer project called "GatherLi" was found on LinkedIn (an environmental community collaboration tool built with Remix/MySQL) — no commercial brand, no registration.
- **Critical risk:** USPTO examiners apply a "sight, sound, and meaning" test. "Gatherli" and "Gatherly" are phonetically near-identical. If any Gatherly entity holds a registered mark in Classes 9, 41, or 42, they could challenge a "Gatherli" filing on phonetic grounds.

### Risk: 🟠 MEDIUM-HIGH
No confirmed conflict for "Gatherli" specifically, but phonetic similarity to established "Gatherly" commercial entities is a real exposure.
⚠️ Manual USPTO TESS search required for both "GATHERLI" and "GATHERLY": https://tmsearch.uspto.gov

---

## 4. EUIPO Trademark — Gatherli

### Findings

No results for "Gatherli" found in any EUIPO-indexed data. Manual verification still required.

### Risk: 🟢 LOW-MEDIUM
No confirmed conflict. Manual check required: https://euipo.europa.eu/eSearch/

---

## 5. Domain Availability — Gatherli

| Domain | Status | Notes |
|--------|--------|-------|
| `gatherli.com` | ⚠️ TAKEN | Registered June 2023 via Name.com. Identity hidden. **Expires June 2026** — acquisition opportunity. No public website. |
| `gatherli.io` | ✅ LIKELY AVAILABLE | No WHOIS record found. |
| `gatherli.app` | ✅ LIKELY AVAILABLE | No WHOIS record found. |
| `gatherli.ch` | ⚠️ TAKEN | Registered. Not owned by project. Likely dormant/parked. |

**Key action:** Register `gatherli.app` and `gatherli.io` immediately — they appear available and are low cost.

**Note on deep linking:** The project owner owns `gatherly.ch` (different spelling). Since the domain in a deep link URL is effectively invisible to most users, `gatherly.ch` can serve as the deep link domain even for an app named "Gatherli":
```
https://gatherly.ch/invite/{token}   ← primary deep link
gatherli://invite/{token}            ← custom scheme fallback
```

---

## 6. Social Media — Gatherli

### Instagram

| Handle | Status |
|--------|--------|
| `@gatherli` | LIKELY AVAILABLE — no active account confirmed in search |

One 2020 Instagram post was found that *mentions* "Gatherli" in a caption, but no account named `@gatherli` was confirmed. Direct check at instagram.com/gatherli required.

### X (Twitter)

| Handle | Status |
|--------|--------|
| `@gatherli` | LIKELY AVAILABLE — no account found in search |

### Risk: 🟢 LOW — Both handles appear available. Direct verification required before launch.

---

## 7. Gatherli Web Presence

The complete web footprint for "Gatherli":

- No company, product, or startup uses "Gatherli" as a brand name
- No app on any major store uses the exact name
- `gatherli.com` registered in 2023 but no public content — likely parked/speculative
- One personal developer project ("GatherLi" — environmental community tool) with no commercial presence

---

---

# Part 3 — Comparative Analysis

---

## Side-by-Side Risk Matrix

| Dimension | Gatherly | Gatherli |
|-----------|----------|----------|
| iOS App Store (exact name conflict) | 🔴 2 apps exist | 🟢 None |
| Google Play (exact name conflict) | 🔴 2 apps exist | 🟢 None |
| Android package namespace | 🔴 `com.gatherly.*` taken | 🟢 Available |
| USPTO trademark (confirmed) | 🔴 Multiple entities, common-law rights | 🟡 None confirmed; phonetic risk re "Gatherly" |
| EUIPO trademark | 🟠 UK entity confirmed, EU filing plausible | 🟢 No confirmed conflict |
| .com domain | 🔴 Taken since 2007 | 🟡 Taken since 2023 — **expires June 2026** |
| .io domain | 🔴 Taken (Gatherly.io, 2020) | 🟢 Appears available |
| .app domain | 🟠 Likely taken | 🟢 Appears available |
| .ch domain | ✅ **Project owns `gatherly.ch`** | ⚠️ `gatherli.ch` taken; `gatherly.ch` (owned) usable for deep links |
| Instagram handle | 🔴 5+ "Gatherly" accounts | 🟢 Likely available |
| X/Twitter handle | 🟠 `@gatherlyio` taken; `@gatherly` unconfirmed | 🟢 Likely available |
| Existing commercial ecosystem | 🔴 Large (VC-backed, legal entities, active apps) | 🟢 Virtually none |
| **Overall** | 🔴 **HIGH** | 🟡 **MEDIUM** |

---

## Recommendation

### Preferred: Proceed with **"Gatherli"**

"Gatherli" presents a meaningfully lower risk profile:
- No existing app on either store under that name
- Package namespace freely available
- `gatherli.app` and `gatherli.io` appear unregistered
- No established commercial entity asserting the name

**Immediate actions if choosing "Gatherli":**
1. Register `gatherli.app` now (appears available, low cost)
2. Register `gatherli.io` now (appears available, low cost)
3. Monitor `gatherli.com` — expires June 8, 2026; set a backorder or contact owner via broker
4. Use `gatherly.ch` (already owned) for deep links — no new domain purchase needed
5. Submit app as **"Gatherli"** on both stores (no subtitle needed given no exact conflict)
6. Use `ch.gatherli.app` as the Android package ID / iOS bundle ID base
7. Engage trademark attorney for phonetic similarity check against "Gatherly" before store submission

### Fallback: **"Gatherly" with mitigations**

If "Gatherly" is preferred for branding reasons:
1. Submit as **"Gatherly Sports"** on both stores
2. Use `ch.gatherly.app` as package ID base
3. Use `gatherly.ch` for deep links
4. Trademark attorney consultation is mandatory before submission

---

## Decision Gate

| Prerequisite | Gatherly | Gatherli |
|-------------|----------|----------|
| Manual USPTO search for exact name | ⬜ Pending | ⬜ Pending |
| Manual USPTO phonetic search ("Gatherly" vs "Gatherli") | — | ⬜ Pending |
| Manual EUIPO search | ⬜ Pending | ⬜ Pending |
| Trademark attorney consulted | ⬜ Recommended | ⬜ Recommended |
| `@[name]` Instagram handle confirmed available | ⬜ Pending | ⬜ Pending |
| `@[name]` X handle confirmed available | ⬜ Pending | ⬜ Pending |
| `gatherli.app` registered | — | ⬜ Action required |
| `gatherli.io` registered | — | ⬜ Action required |
| App Store submission name decided | ⬜ Pending | ⬜ Pending |
| Android package ID base decided | ⬜ Pending | ⬜ Pending |
| **`gatherly.ch` confirmed owned** | ✅ Confirmed | ✅ Usable for deep links |

---

## Sources

- [Gatherly Connect: Hangouts — App Store](https://apps.apple.com/us/app/gatherly-connect-hangouts/id6477335688)
- [Gatherly — Your Social Spot — Google Play](https://play.google.com/store/apps/details?id=com.dc.gatherly)
- [Gatherly Social — Google Play](https://play.google.com/store/apps/details?id=com.gatherly.gatherly)
- [Gatherly.io](https://www.gatherly.io)
- [Gatherly joins GoLocal Virtual Events](https://www.gatherly.io/post/a-larger-duddle-gatherly-joins-golocal-virtual-events)
- [Gatherly — Crunchbase](https://www.crunchbase.com/organization/gatherly)
- [WHOIS gatherli.com — who.is](https://who.is/whois/gatherli.com)
- [USPTO Trademark Search](https://tmsearch.uspto.gov/search/search-information)
- [EUIPO Trade Mark Search](https://euipo.europa.eu/eSearch/)
