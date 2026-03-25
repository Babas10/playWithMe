-- Gatherli — BigQuery Analytics Queries
-- Story 24.3: Firebase → BigQuery export
--
-- Usage:
--   Replace PROJECT_ID and PROPERTY_ID with your actual values before running.
--   Find PROPERTY_ID in: Firebase Console → Project Settings → Integrations → BigQuery → View in BigQuery.
--
--   Default dataset name: analytics_<PROPERTY_ID>
--   Default table pattern: `PROJECT_ID.analytics_PROPERTY_ID.events_*`
--
-- All queries target the Firebase Analytics BigQuery export (Source 1).
-- See docs/epic-24/story-24.3/EVENT_SCHEMA.md for the full event catalog.
-- ============================================================================


-- ============================================================================
-- HELPER: shared date range macro
-- Adjust the WHERE clause in each query to narrow the date range.
-- ============================================================================

-- Standard 30-day lookback filter (add to any query):
--   WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
--                             AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())


-- ============================================================================
-- 1. DAILY ACTIVE USERS (DAU)
--    One row per day: distinct users who had at least one session.
-- ============================================================================

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS date,
  COUNT(DISTINCT user_pseudo_id)   AS dau
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name = 'session_start'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY date
ORDER BY date;


-- ============================================================================
-- 2. WEEKLY ACTIVE USERS (WAU) + MONTHLY ACTIVE USERS (MAU)
-- ============================================================================

SELECT
  DATE_TRUNC(PARSE_DATE('%Y%m%d', event_date), WEEK(MONDAY)) AS week_start,
  COUNT(DISTINCT user_pseudo_id)                              AS wau
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name = 'session_start'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY week_start
ORDER BY week_start;


-- ============================================================================
-- 3. NEW USERS VS RETURNING USERS per day
--    first_open = new install; session_start without first_open = returning.
-- ============================================================================

SELECT
  PARSE_DATE('%Y%m%d', event_date)                                AS date,
  COUNT(DISTINCT IF(event_name = 'first_open', user_pseudo_id, NULL)) AS new_users,
  COUNT(DISTINCT IF(event_name = 'session_start', user_pseudo_id, NULL))
    - COUNT(DISTINCT IF(event_name = 'first_open', user_pseudo_id, NULL)) AS returning_users
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name IN ('first_open', 'session_start')
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY date
ORDER BY date;


-- ============================================================================
-- 4. PLATFORM SPLIT
--    Android vs iOS share over the last 30 days.
-- ============================================================================

SELECT
  platform,
  COUNT(DISTINCT user_pseudo_id) AS users,
  ROUND(COUNT(DISTINCT user_pseudo_id) * 100.0
    / SUM(COUNT(DISTINCT user_pseudo_id)) OVER (), 1) AS pct
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name = 'first_open'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY platform;


-- ============================================================================
-- 5. SCREEN VIEWS — top 10 most visited screens
--    Requires screen_view events (Flutter navigation observer).
-- ============================================================================

SELECT
  (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'firebase_screen' LIMIT 1)
    AS screen_name,
  COUNT(*)                         AS views,
  COUNT(DISTINCT user_pseudo_id)   AS unique_users
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name = 'screen_view'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY screen_name
ORDER BY views DESC
LIMIT 10;


-- ============================================================================
-- 6. CRASH RATE — crashes per 1 000 sessions per day
--    Uses app_exception events (fatal=1) from Crashlytics → BigQuery export.
-- ============================================================================

WITH sessions AS (
  SELECT
    event_date,
    COUNT(DISTINCT user_pseudo_id) AS sessions
  FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
  WHERE
    event_name = 'session_start'
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY event_date
),
crashes AS (
  SELECT
    event_date,
    COUNT(*) AS crash_count
  FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
  WHERE
    event_name = 'app_exception'
    AND (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'fatal' LIMIT 1) = 1
    AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY))
                          AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
  GROUP BY event_date
)
SELECT
  PARSE_DATE('%Y%m%d', s.event_date) AS date,
  s.sessions,
  COALESCE(c.crash_count, 0)         AS crashes,
  ROUND(COALESCE(c.crash_count, 0) * 1000.0 / NULLIF(s.sessions, 0), 2) AS crashes_per_1k_sessions
FROM sessions s
LEFT JOIN crashes c USING (event_date)
ORDER BY date;


-- ============================================================================
-- 7. APP VERSION ADOPTION
--    How quickly users migrate to new builds.
-- ============================================================================

SELECT
  app_info.version                 AS app_version,
  COUNT(DISTINCT user_pseudo_id)   AS users,
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_seen
FROM `PROJECT_ID.analytics_PROPERTY_ID.events_*`
WHERE
  event_name = 'session_start'
  AND _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 60 DAY))
                        AND FORMAT_DATE('%Y%m%d', CURRENT_DATE())
GROUP BY app_version
ORDER BY users DESC;


-- ============================================================================
-- NOTES ON SOURCE 2 (Firestore analytics_events collection)
-- ============================================================================
-- The events below (game_created, invitation_sent, etc.) are written to the
-- Firestore `analytics_events` collection by Cloud Function triggers (Story 24.2).
-- They are NOT in the Firebase Analytics BigQuery dataset above.
--
-- To query them in BigQuery, set up the official Firestore → BigQuery extension:
--   https://extensions.dev/extensions/firebase/firestore-bigquery-export
-- Configure it to mirror the `analytics_events` collection.
-- The extension creates a `firestore_export` dataset with a `analytics_events_raw_*`
-- table that can be queried with standard SQL.
--
-- Example query once the extension is set up:
--
-- SELECT
--   JSON_VALUE(data, '$.event')                        AS event_name,
--   TIMESTAMP_MICROS(CAST(timestamp AS INT64))         AS occurred_at,
--   JSON_VALUE(data, '$.properties.groupId')           AS group_id,
--   JSON_VALUE(data, '$.properties.sport')             AS sport
-- FROM `PROJECT_ID.firestore_export.analytics_events_raw_latest`
-- WHERE JSON_VALUE(data, '$.event') = 'game_created'
-- ORDER BY occurred_at DESC;
--
-- Invitation conversion rate (backend events):
--
-- SELECT
--   DATE(TIMESTAMP_MICROS(CAST(timestamp AS INT64))) AS date,
--   COUNTIF(JSON_VALUE(data, '$.event') = 'invitation_sent')     AS sent,
--   COUNTIF(JSON_VALUE(data, '$.event') = 'invitation_accepted') AS accepted,
--   ROUND(
--     SAFE_DIVIDE(
--       COUNTIF(JSON_VALUE(data, '$.event') = 'invitation_accepted'),
--       COUNTIF(JSON_VALUE(data, '$.event') = 'invitation_sent')
--     ) * 100, 1
--   ) AS conversion_pct
-- FROM `PROJECT_ID.firestore_export.analytics_events_raw_latest`
-- WHERE JSON_VALUE(data, '$.event') IN ('invitation_sent', 'invitation_accepted')
-- GROUP BY date
-- ORDER BY date;
