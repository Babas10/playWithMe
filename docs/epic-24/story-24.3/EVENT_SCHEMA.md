# Gatherli — Analytics Event Schema

**Epic 24 / Story 24.3**
**Last updated:** 2026-03-24

---

## Overview: Two Data Sources

Gatherli's analytics pipeline has **two independent data sources** that land in different places.
Understanding which one to query is the first step before writing any SQL.

| Source | What it captures | Where it lands | How to query |
|--------|-----------------|----------------|--------------|
| **Firebase Analytics SDK** (client-side) | Screen views, session starts, first opens, app exceptions, any `logEvent()` call from the Flutter app | BigQuery — `analytics_<PROPERTY_ID>.events_YYYYMMDD` tables | Standard SQL via BigQuery console or Looker Studio |
| **Firestore `analytics_events` collection** (backend) | Business events emitted by Cloud Function triggers (game created, invitation sent, etc.) | Firestore only — not in BigQuery | Firestore console, or export via Firestore → BigQuery extension |

> **Note:** The Firebase Analytics → BigQuery export (enabled in Story 24.3) covers **source 1 only**.
> To query source 2 events in BigQuery, either set up the
> [Firestore → BigQuery extension](https://extensions.dev/extensions/firebase/firestore-bigquery-export)
> or migrate the backend events to use `FirebaseAnalytics.instance.logEvent()` calls from a Cloud
> Function HTTP endpoint. This is tracked as a future improvement.

---

## Source 1: Firebase Analytics BigQuery Export

### Table location

```
Project:  gatherli-prod
Dataset:  analytics_<PROPERTY_ID>          -- replace with your GA property ID
Tables:   events_YYYYMMDD                  -- one table per day (partitioned)
          events_intraday_YYYYMMDD         -- today's partial data (refreshes hourly)
```

Find your property ID in: Firebase Console → Project Settings → Integrations → BigQuery → View in BigQuery.

### Core table schema

The `events_*` tables have the same schema. Key columns:

| Column | Type | Description |
|--------|------|-------------|
| `event_date` | STRING | Date as `YYYYMMDD` |
| `event_timestamp` | INT64 | Microseconds since Unix epoch |
| `event_name` | STRING | Name of the event (e.g. `session_start`, `screen_view`) |
| `event_params` | ARRAY\<STRUCT\<key STRING, value STRUCT\<…\>\>\> | Event parameters as key-value pairs |
| `user_pseudo_id` | STRING | Anonymous user identifier (not a UID) |
| `user_id` | STRING | Firebase Auth UID — only populated if `setUserId()` is called |
| `device.operating_system` | STRING | `IOS` or `ANDROID` |
| `device.language` | STRING | Device locale |
| `geo.country` | STRING | Country |
| `app_info.version` | STRING | App version (e.g. `1.0.0`) |
| `platform` | STRING | `IOS`, `ANDROID`, or `WEB` |

### Reading event parameters

Event parameters are stored as a repeated struct, not flat columns. Use a helper macro:

```sql
-- Extract a string parameter value from event_params
CREATE TEMP FUNCTION get_string_param(params ANY TYPE, key STRING) AS (
  (SELECT value.string_value FROM UNNEST(params) WHERE key = key LIMIT 1)
);

-- Extract an integer parameter value from event_params
CREATE TEMP FUNCTION get_int_param(params ANY TYPE, key STRING) AS (
  (SELECT value.int_value FROM UNNEST(params) WHERE key = key LIMIT 1)
);
```

---

## Source 1: Automatic Firebase Analytics Events

These are emitted by the Firebase Analytics SDK without any custom code.

| Event name | When it fires | Key params |
|-----------|---------------|------------|
| `first_open` | First time user opens the app after install | — |
| `session_start` | Start of a new session (30 min inactivity threshold) | — |
| `user_engagement` | User spends time in the foreground | `engagement_time_msec` |
| `screen_view` | Every screen navigation (requires `reportFullyDrawn` or navigation observer) | `firebase_screen`, `firebase_previous_screen` |
| `app_exception` | Crash or non-fatal exception (from Crashlytics integration) | `fatal` (1=crash, 0=non-fatal), `timestamp` |
| `os_update` | User updated their OS | `previous_os_version` |
| `app_update` | User updated the app | `previous_app_version` |

---

## Source 1: Custom Firebase Analytics Events (Planned)

These events should be added in a future story via `FirebaseAnalytics.instance.logEvent()` calls in the Flutter app. They complement the backend events below by capturing the user's journey through the UI.

| Event name | Where to fire | Proposed params |
|-----------|---------------|----------------|
| `join_group_tapped` | Group invite acceptance screen | `source: 'link' \| 'notification'` |
| `game_rsvp` | RSVP action | `response: 'join' \| 'decline' \| 'waitlist'` |
| `profile_photo_uploaded` | Photo upload complete | — |
| `deep_link_opened` | Deferred deep link resolved | `type: 'group_invite'` |

---

## Source 2: Firestore `analytics_events` Collection

These events are written by Cloud Function triggers (Story 24.2). Each document has the following shape:

```
analytics_events/{auto-id}
├── event: string        -- event name (see catalog below)
├── timestamp: Timestamp -- server timestamp of the write
└── properties: map      -- event-specific properties (no UIDs, names, or emails)
```

### Event catalog

#### `game_created`
Fires when a new game document is created.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group the game belongs to |
| `sport` | string | Sport type (e.g. `volleyball`, `basketball`), or `unknown` if not set |

---

#### `game_cancelled`
Fires when a game's status transitions to `cancelled`.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group |

---

#### `invitation_sent`
Fires when a new invitation document is created for a user.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group the invitation is for |

---

#### `invitation_accepted`
Fires when an invitation's status transitions from `pending` to `accepted`.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group |

---

#### `member_joined`
Fires once per new member detected in a group's `memberIds` array. Emitted inside the loop, so one event per member even if multiple join simultaneously.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group |
| `via` | string | Join path — currently always `unknown`; will be refined when invite-link vs direct invite is distinguishable |

---

#### `waitlist_promoted`
Fires when one or more users are promoted from the waitlist to the player list on a game.

| Property | Type | Description |
|----------|------|-------------|
| `groupId` | string | Firestore ID of the group |
| `gameId` | string | Firestore ID of the game |

---

#### `friend_connected`
Fires when a friendship document's status transitions to `accepted`.

| Property | Type | Description |
|----------|------|-------------|
| *(none)* | — | Only the count matters; no properties to avoid linking two parties |

---

## Privacy Rules

These rules are enforced at write time in `functions/src/helpers/analytics.ts` by convention:

- ❌ Never store Firebase Auth UIDs in event properties
- ❌ Never store display names or email addresses
- ❌ Never store Firestore document IDs that can be reverse-mapped to a user identity
- ✅ Group IDs and game IDs are acceptable (they identify content, not people)
- ✅ Aggregate counts and boolean flags are acceptable

---

## Adding New Events

**Backend (Cloud Function):**
```typescript
import { writeAnalyticsEvent } from "./helpers/analytics";

// Inside a trigger handler, after all business logic:
await writeAnalyticsEvent("event_name", { groupId, someProperty: "value" });
```

**Flutter (client-side):**
```dart
await FirebaseAnalytics.instance.logEvent(
  name: 'event_name',
  parameters: {'screen': 'game_detail'},
);
```

Add the new event to this document before merging.
