# Story 18.1 — Pre-flight: Name & Domain Availability Check

**Research Date:** 2026-02-27
**Epic:** 18 — App Rename: PlayWithMe → Gatherly
**Issue:** #507

---

## Executive Summary

**Overall Risk: HIGH**

The name "Gatherly" is significantly occupied across mobile app stores, domains, social handles, and has established commercial entities asserting IP rights. However, the project owner **already owns `gatherly.ch`**, which serves as the foundation for a Switzerland/Europe-first strategy and resolves the deep linking domain question. A final go/no-go decision requires manual trademark verification (USPTO + EUIPO) before proceeding with Stories 18.2–18.11.

---

## 1. Apple App Store

### Findings

Two distinct apps already named "Gatherly" are live on the iOS App Store:

| App | Developer | Category |
|-----|-----------|----------|
| **Gatherly Connect: Hangouts** (id6477335688) | ExponentialsSuccess | Social / Event discovery |
| **Gatherly Social** (id6461268313) | Gatherly Social Inc. | Social / Meal meetups |

- **Gatherly Connect** helps users find local hangouts, events, beach walks — closely adjacent to a sports social app.
- **Gatherly Social** matches users for group dinners; also a social coordination overlap.

### Risk: HIGH
Apple's App Store review team flags name conflicts during submission. An existing developer could file an App Store dispute. The app name "Gatherly" alone (without a subtitle) will likely be rejected as a duplicate.

**Mitigation options:**
- Use a distinct subtitle: e.g., "Gatherly — Beach Volleyball" or "Gatherly Sports"
- Register a unique brand name variant before submitting

---

## 2. Google Play Store

### Findings

Two Android apps also use the "Gatherly" name:

| App | Package | Developer |
|-----|---------|-----------|
| **Gatherly — Your Social Spot** | `com.dc.gatherly` | ExponentialsSuccess |
| **Gatherly Social** | `com.gatherly.gatherly` | Gatherly Social Inc. |

The package namespace **`com.gatherly.*` is already claimed** by Gatherly Social Inc.

### Risk: HIGH
Google Play can reject or challenge submissions with name conflicts. The `com.gatherly` package prefix cannot be used — it's already registered. The planned `com.gatherly.app` package ID must be changed.

**Recommendation:** Use `com.gatherlyapp` or `app.gatherly` or a country-scoped alternative like `ch.gatherly.app`.

---

## 3. USPTO Trademark (United States)

### Findings

Multiple commercial entities have been operating under "Gatherly" since at least 2020:

| Entity | Type | Since |
|--------|------|-------|
| **Gatherly.io** (now GoLocal Virtual Events) | VC-backed B2B virtual events SaaS | 2020 |
| **Gatherly Social Inc.** | Legal entity, social app | ~2022 |
| **Gatherly Connect** | Consumer social app | ~2023 |

Even without a formal USPTO registration, **common law trademark rights** arise from commercial use in the US. These entities likely hold enforceable claims in software/app categories (Class 9) and social platform services (Class 42).

### Risk: HIGH
⚠️ **A formal USPTO TESS search is mandatory** before proceeding. Common law rights from existing Gatherly commercial use are a real legal exposure.

**Action required:** Manual search at https://tmsearch.uspto.gov for "GATHERLY" in:
- Class 9 (downloadable software/apps)
- Class 41 (entertainment/event services)
- Class 42 (SaaS/tech platform services)

---

## 4. EUIPO Trademark (European Union)

### Findings

- **Gatherly.io** domain is registered to a UK-based entity (Middlesex, GB), confirming European operations.
- Companies of Gatherly.io's scale routinely file EU trademark protection.
- No confirmed EU registration found via automated search — **manual verification required**.

### Risk: Medium-High
A manual search at https://euipo.europa.eu/eSearch/ for "Gatherly" in classes 9, 41, 42 is required. Given that the project targets European users and `gatherly.ch` is already owned by the project, EU trademark clearance is critical.

---

## 5. Domain Availability

| Domain | Status | Owner / Notes |
|--------|--------|---------------|
| `gatherly.com` | **TAKEN** | Registered since 2007. UK-based registrant. Hosted on HostGator. |
| `gatherly.io` | **TAKEN** | Gatherly Virtual Events (now GoLocal). Registered 2020. AWS nameservers. |
| `gatherly.org` | **TAKEN** | Community events platform ("A simple and seamless way to gather together!") |
| `gatherly.app` | **LIKELY TAKEN** | Associated with "Gatherly — Your Social Spot" app. WHOIS not publicly exposed for .app TLD. Verify at https://get.app/ |
| **`gatherly.ch`** | **✅ OWNED** | Already registered by the project owner. Confirmed. |

### Deep Linking Recommendation

Since `gatherly.ch` is already owned, it should serve as the **primary deep link domain** for the app:

```
https://gatherly.ch/invite/{token}     ← primary
gatherly://invite/{token}              ← custom scheme fallback
```

This avoids the need to acquire `gatherly.app` and aligns with the Switzerland-first identity. The `ch` TLD also gives the product a distinct European identity that differentiates from the US-based "Gatherly" entities.

---

## 6. Social Media Handles

### Instagram

| Handle | Status | Account |
|--------|--------|---------|
| `@gatherly_io` | TAKEN | Gatherly Virtual Events (28 followers, 111 posts) |
| `@gatherlyio` | TAKEN | Gatherly Virtual Events (secondary account) |
| `@joingatherly` | TAKEN | Social community app, Victoria BC (2,140 followers) |
| `@gogatherly` | TAKEN | Community events |
| `@gatherlyhk` | TAKEN | Hong Kong-based |
| `@gatherly` | UNKNOWN | Direct verification required on Instagram |

### X (Twitter)

| Handle | Status | Account |
|--------|--------|---------|
| `@gatherlyio` | TAKEN | Gatherly Virtual Events (created 2020, inactive) |
| `@gatherly` | UNKNOWN | Not surfaced in search — direct verification required |

**Risk: HIGH** — Five+ "Gatherly" accounts on Instagram create significant brand confusion. Consider `@gatherlyapp` or `@joingatherlyapp` as alternative handles.

---

## 7. Full Gatherly Ecosystem Map

| Entity | Type |
|--------|------|
| Gatherly.io / GoLocal Virtual Events | B2B Virtual Events SaaS (VC-backed, acquired 2024) |
| Gatherly Connect: Hangouts | iOS/Android consumer social app |
| Gatherly Social Inc. | Meal-matching social app (iOS + Android) |
| gatherly.org | Community events platform |
| @joingatherly (Instagram) | Social community, 2,140 followers |
| @gatherlyio (X) | Virtual events company |

---

## 8. Risk Matrix

| Dimension | Risk | Notes |
|-----------|------|-------|
| Apple App Store name | HIGH | 2 existing "Gatherly" apps in social category |
| Google Play name | HIGH | 2 existing apps; `com.gatherly.*` namespace taken |
| Google Play package ID | HIGH | `com.gatherly.app` cannot be used |
| USPTO Trademark | HIGH | Multiple entities with common-law rights |
| EUIPO Trademark | Medium-High | UK-based operations confirmed; EU filing plausible |
| gatherly.com / .io / .org | HIGH | All taken and actively used |
| gatherly.app | Medium | Likely taken; WHOIS hidden |
| **gatherly.ch** | ✅ CLEAR | Already owned by project |
| Instagram `@gatherly` | Medium | Unconfirmed; heavy surrounding occupancy |
| X `@gatherly` | Medium | Unconfirmed; `@gatherlyio` taken |

---

## 9. Recommendations

### Option A: Proceed with "Gatherly" (Mitigated Risk)

If the decision is to proceed with the "Gatherly" name:

1. **App Store names:** Submit as **"Gatherly Sports"** or **"Gatherly — Play Together"** to differentiate from existing apps
2. **Package ID:** Use `ch.gatherly.app` (reversed domain from `gatherly.ch`) instead of `com.gatherly.app`
3. **Deep linking domain:** Use `gatherly.ch` (already owned) — no new domain purchase needed
4. **Trademark:** Engage a trademark attorney to assess clearance risk in CH/EU before filing and submitting to stores
5. **Social handles:** Use `@gatherlyapp` or `@gatherlyapp_ch` on both platforms

### Option B: Choose an Alternative Name

If trademark risk is unacceptable, consider names with no existing mobile app or trademark conflicts. Criteria: sports/social angle, available on both stores, clear domain availability.

---

## 10. Decision Gate

| Prerequisite | Status |
|-------------|--------|
| Manual USPTO search completed | ⬜ Pending |
| Manual EUIPO search completed | ⬜ Pending |
| `@gatherly` Instagram availability confirmed | ⬜ Pending |
| `@gatherly` X availability confirmed | ⬜ Pending |
| gatherly.app WHOIS confirmed | ⬜ Pending |
| Trademark attorney consulted (if proceeding) | ⬜ Recommended |
| App Store submission name decided ("Gatherly Sports"?) | ⬜ Pending |
| Android package ID decided (`ch.gatherly.app`?) | ⬜ Pending |
| **gatherly.ch domain confirmed owned** | ✅ Confirmed |

---

## Sources

- [Gatherly Connect: Hangouts — App Store](https://apps.apple.com/us/app/gatherly-connect-hangouts/id6477335688)
- [Gatherly — Your Social Spot — Google Play](https://play.google.com/store/apps/details?id=com.dc.gatherly)
- [Gatherly Social — Google Play](https://play.google.com/store/apps/details?id=com.gatherly.gatherly)
- [Gatherly.io](https://www.gatherly.io)
- [Gatherly joins GoLocal Virtual Events](https://www.gatherly.io/post/a-larger-huddle-gatherly-joins-golocal-virtual-events)
- [Gatherly — Crunchbase](https://www.crunchbase.com/organization/gatherly)
- [USPTO Trademark Search](https://tmsearch.uspto.gov/search/search-information)
- [EUIPO Trade Mark Search](https://euipo.europa.eu/eSearch/)
