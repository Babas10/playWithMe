# Epic 24: Product Analytics & Observability

## Goal

Instrument the Gatherli app and backend to capture meaningful product metrics
before users arrive — so the first week of real usage produces actionable data
rather than a blank dashboard.

---

## Background

Analytics must be set up *before* users arrive. There is no way to retroactively
reconstruct what users did in the past. A common mistake is to ship an app, get
early users, and only then realise you cannot answer basic questions like "how
many games were created this week?" or "what percentage of invited users actually
joined a group?".

Gatherli's architecture — Firebase + Cloud Functions — is particularly well-suited
for server-side analytics. Every meaningful action (game created, member joined,
invite accepted) already goes through a Cloud Function trigger. Adding analytics
there is one line per event and is immune to client-side ad blockers or app crashes
before the event fires.

---

## The Metrics That Matter for Gatherli

Before instrumenting anything, it is worth being explicit about which questions
the data needs to answer. These fall into three categories:

### Acquisition
- How many new users signed up this week/month?
- What is the source of new users? (direct, invite link, word of mouth)
- What percentage of invite links result in a signup?

### Activation
- How many new users created or joined a group within 24 hours of signing up?
- How long does it take from signup to first game?
- What percentage of users who created a group also created a game?

### Engagement & Retention
- How many games are created per group per month?
- What is the average RSVP rate per game?
- What percentage of users return on Day 1, Day 7, Day 30?
- Which groups are active vs. dormant?

### Health
- Crash rate (crashes per session)
- Cloud Function error rate
- App launch time

---

## Architecture Overview

```
Flutter app
    │
    ├── Firebase Analytics (passive: sessions, retention, crashes via Crashlytics)
    └── Custom events (active: game_created, rsvp_submitted, invite_accepted, ...)
            │
            └── Cloud Functions (server-side, reliable, not blockable)
                        │
                        └── Firestore analytics_events collection
                                    │
                                    └── BigQuery export (automatic, daily)
                                                │
                                                └── Looker Studio dashboard
```

The client-side Firebase Analytics SDK handles passive metrics for free.
All meaningful business events are written server-side from Cloud Function triggers
— this is more reliable than client-side event logging and requires no changes to
the Flutter app's business logic.

---

## Stories

| Story | Title | Layer |
|-------|-------|-------|
| 24.1 | Add Firebase Analytics and Crashlytics to the Flutter app | Client |
| 24.2 | Instrument Cloud Function triggers with analytics events | Backend |
| 24.3 | Enable Firebase → BigQuery export and define event schema | Data |
| 24.4 | Add client-side custom events for key user actions | Client |
| 24.5 | Build Looker Studio dashboard for core product metrics | Dashboard |

---

## Story Detail

---

### Story 24.1 — Add Firebase Analytics and Crashlytics to the Flutter app

**Category:** Client — Passive metrics baseline

**What this gives you immediately (zero config after adding the packages):**
- Daily Active Users and Monthly Active Users
- Session count and average session duration
- New vs. returning users
- User retention cohorts (Day 1, Day 7, Day 30)
- Platform and device breakdown (iOS vs Android, OS version)
- App version distribution (important for knowing when users have updated)
- Crash-free user rate and crash reports with stack traces (Crashlytics)

**Packages to add to `pubspec.yaml`:**
```yaml
firebase_analytics: ^10.x.x
firebase_crashlytics: ^4.x.x
```

**Initialisation in `main_prod.dart`:**
```dart
// Pass all Flutter errors to Crashlytics
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

// Pass async errors
PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

**Why Crashlytics before any users:**
Crashlytics gives you a crash-free user rate from day one. Without it, you will
only discover crashes when users complain — and most users don't complain, they
just uninstall.

**Benefit:**
- The most important retention and acquisition metrics are available on day one
  with no additional instrumentation.
- Crashes are caught and reported automatically with full stack traces.
- Free, already in the Firebase project.

**Acceptance Criteria:**
- [ ] `firebase_analytics` and `firebase_crashlytics` added to `pubspec.yaml`
- [ ] Crashlytics initialised in both `main_prod.dart` and `main_dev.dart`
- [ ] Flutter and async errors routed to Crashlytics
- [ ] Test crash visible in Firebase Crashlytics console (dev project)
- [ ] Analytics events visible in Firebase DebugView (dev project)

---

### Story 24.2 — Instrument Cloud Function triggers with analytics events

**Category:** Backend — Server-side business events

**Why server-side, not client-side:**
Client-side analytics can be lost if the app crashes before the event fires, if
the user has an ad blocker, or if there is a network issue at the moment of the
event. Server-side events written from Cloud Function triggers fire reliably —
by the time the trigger runs, the data is already in Firestore.

**Existing triggers to instrument:**
Every trigger below already exists. Each one needs a single `analytics_events`
write added:

| Trigger | Event name | Key properties |
|---------|------------|----------------|
| `onGameCreated` | `game_created` | `groupId`, `sport`, `scheduledAt` |
| `onMemberJoined` | `member_joined` | `groupId`, `via` (invite_link / direct_invite) |
| `onInvitationCreated` | `invitation_sent` | `groupId`, `inviterId` |
| `onInvitationAccepted` | `invitation_accepted` | `groupId`, `inviterId` |
| `onGameCancelled` | `game_cancelled` | `groupId`, `reason` |
| `onWaitlistPromoted` | `waitlist_promoted` | `groupId`, `gameId` |
| `onFriendRequestAccepted` | `friend_connected` | — (count only, no user IDs) |

**Event schema (consistent across all events):**
```typescript
interface AnalyticsEvent {
  event: string;               // snake_case event name
  timestamp: Timestamp;        // server timestamp
  properties: Record<string, string | number | boolean>;  // no PII
}
```

**Privacy rule:** Never log user IDs, display names, emails, or any data that
could identify a specific user in analytics events. Log group IDs and game IDs
(internal references) only. This keeps analytics GDPR-compliant.

**Implementation pattern (added to each existing trigger):**
```typescript
// At the end of onGameCreated, after the notification logic:
await admin.firestore().collection('analytics_events').add({
  event: 'game_created',
  timestamp: admin.firestore.FieldValue.serverTimestamp(),
  properties: {
    sport: gameData.sport ?? 'unknown',
    groupId: gameData.groupId,
  },
});
```

**Benefit:**
- Business metrics (games created, invites accepted, members joined) are captured
  reliably without any client-side changes.
- The data lives in Firestore and is automatically exported to BigQuery (Story 24.3).
- Adding a new metric in the future requires only adding one `analytics_events`
  write to an existing trigger.

**Acceptance Criteria:**
- [ ] `analytics_events` collection documented in Firestore schema
- [ ] All 7 triggers above write a corresponding analytics event
- [ ] Events contain no PII (no user IDs, names, or emails)
- [ ] Unit tests updated for each modified trigger
- [ ] Events visible in Firestore console (dev environment) after a test game creation

---

### Story 24.3 — Enable Firebase → BigQuery export and define event schema

**Category:** Data — Export and queryable storage

**What BigQuery gives you:**
BigQuery is Google's serverless data warehouse. Firebase has a built-in one-click
export that sends all Firestore Analytics events and the `analytics_events`
collection to BigQuery daily (or in streaming mode for near-real-time).

Once data is in BigQuery, you can answer any question with SQL — without building
a custom backend, without paying for a third-party analytics tool, and without
waiting for a vendor to add the specific metric you need.

**Example queries immediately available after setup:**
```sql
-- Games created per week
SELECT DATE_TRUNC(DATE(timestamp), WEEK) AS week, COUNT(*) AS games_created
FROM `gatherli-prod.analytics.analytics_events`
WHERE event = 'game_created'
GROUP BY week ORDER BY week DESC;

-- Invite conversion rate (accepted / sent)
SELECT
  COUNTIF(event = 'invitation_accepted') / COUNTIF(event = 'invitation_sent') AS conversion_rate
FROM `gatherli-prod.analytics.analytics_events`
WHERE DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);

-- Most active groups (by games created)
SELECT properties.groupId, COUNT(*) AS games
FROM `gatherli-prod.analytics.analytics_events`
WHERE event = 'game_created'
GROUP BY properties.groupId ORDER BY games DESC LIMIT 20;
```

**Setup steps:**
1. In the Firebase console → Project settings → Integrations → BigQuery → Link
2. Select the `analytics_events` collection for export
3. Enable streaming export (near-real-time) vs. daily batch (free tier)
4. In BigQuery console, verify the dataset `gatherli-prod` is populated

**Cost:** The Firebase → BigQuery export itself is free. BigQuery charges for
queries (first 1 TB/month free, then $5/TB). At Gatherli's scale for the
foreseeable future, the cost will be $0.

**Benefit:**
- All analytics data is queryable with SQL, forever, at no additional cost.
- No vendor lock-in — the data is in your GCP project.
- Foundation for the Looker Studio dashboard (Story 24.5).

**Acceptance Criteria:**
- [ ] Firebase → BigQuery export enabled for `gatherli-prod`
- [ ] `analytics_events` collection exported to BigQuery
- [ ] Firebase Analytics events (sessions, retention) also exported
- [ ] At least 3 example queries documented and returning expected results
- [ ] BigQuery dataset permissions locked to the team (not public)

---

### Story 24.4 — Add client-side custom events for key user actions

**Category:** Client — Intent and funnel events

**What server-side events cannot capture:**
The Cloud Function triggers in Story 24.2 capture completed actions (a game was
created). They cannot capture *intent* — a user who opened the "Create Game" screen
but abandoned the form, or a user who viewed an invite link but did not install.
These funnel drop-off points are critical for understanding where users get stuck.

**Key events to add client-side:**
```dart
// User opened the create game screen (intent)
await FirebaseAnalytics.instance.logEvent(name: 'create_game_started');

// User completed onboarding
await FirebaseAnalytics.instance.logEvent(name: 'onboarding_completed');

// User viewed an invite link (before installing)
await FirebaseAnalytics.instance.logEvent(name: 'invite_link_viewed');

// User opened the RSVP screen
await FirebaseAnalytics.instance.logEvent(name: 'rsvp_screen_opened', parameters: {
  'game_status': game.status.name,
});

// User searched for a group (if search is added)
await FirebaseAnalytics.instance.logEvent(name: 'group_search_performed');
```

**Where to log these:**
In the BLoC `mapEventToState` handlers — not in widgets. This keeps analytics
calls out of the UI layer and makes them testable.

**Privacy:** `logEvent` parameters must never contain user IDs, names, or emails.
Group IDs and game IDs are acceptable (they are internal references, not PII).

**Benefit:**
- Reveals funnel drop-off: how many users start creating a game vs. how many
  complete it?
- Onboarding completion rate — the most important activation metric.
- Visible in Firebase Analytics DebugView during development for instant feedback.

**Acceptance Criteria:**
- [ ] `FirebaseAnalytics.instance` injected via `get_it` (not called directly in widgets)
- [ ] At minimum 5 key funnel events instrumented
- [ ] Events visible in Firebase Analytics DebugView
- [ ] No PII in event parameters
- [ ] Events documented in `docs/epic-24/EVENT_CATALOGUE.md`

---

### Story 24.5 — Build Looker Studio dashboard for core product metrics

**Category:** Dashboard — Weekly visibility

**What Looker Studio is:**
Looker Studio (formerly Google Data Studio) is Google's free dashboard tool.
It connects directly to BigQuery and lets you build visual dashboards with no
code. It refreshes automatically and can be shared with a link — no login required
for viewers.

**The dashboard to build — one page, six charts:**

| Chart | Metric | Source |
|-------|--------|--------|
| Line chart | New users per day (last 30 days) | Firebase Analytics → BigQuery |
| Line chart | Games created per day (last 30 days) | `analytics_events` WHERE event = 'game_created' |
| Scorecard | Total groups created (all time) | `analytics_events` WHERE event = 'member_joined' GROUP BY groupId |
| Bar chart | Invite conversion rate (sent → accepted) | `analytics_events` |
| Table | Retention: D1, D7, D30 (last cohort) | Firebase Analytics retention report |
| Scorecard | Crash-free user rate (last 7 days) | Crashlytics → BigQuery |

**Why Looker Studio over Mixpanel/Amplitude at this stage:**
Third-party analytics tools (Mixpanel, Amplitude) are powerful but add cost and
a dependency. Since all the data is already in BigQuery, Looker Studio gives you
90% of the value for free, with no data leaving your GCP project. Migrating to
Mixpanel later is straightforward — the events are already defined.

**Setup steps:**
1. Go to lookerstudio.google.com → Create → Report
2. Connect data source: BigQuery → select `gatherli-prod` dataset
3. Build the six charts above
4. Share the dashboard URL with the team (view-only, no login required)

**Benefit:**
- A single URL the whole team can check on Monday morning.
- No SQL knowledge required to read the dashboard.
- Free, refreshes automatically, lives in your GCP project.

**Acceptance Criteria:**
- [ ] Looker Studio report connected to `gatherli-prod` BigQuery dataset
- [ ] All 6 charts implemented and showing real data (from dev environment at minimum)
- [ ] Dashboard URL shared with the team
- [ ] Dashboard URL documented in `docs/epic-24/`
- [ ] Report auto-refreshes daily

---

## Acceptance Criteria (Epic Level)

All 5 stories are implemented and the following questions can be answered from
the dashboard without writing any new code:

1. How many new users signed up this week?
2. How many games were created this month?
3. What is the invite link conversion rate?
4. What is the Day 7 retention rate?
5. What is the crash-free user rate?

## Out of Scope

- Real-time alerting (e.g. PagerDuty when crash rate spikes) — future epic
- A/B testing framework — future epic
- Mixpanel/Amplitude migration — revisit when scale justifies the cost
- Per-user analytics or user-level tracking — GDPR concern, out of scope
