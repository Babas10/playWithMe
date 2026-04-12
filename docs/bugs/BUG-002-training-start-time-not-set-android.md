# BUG-002 — Training Session Start Time Not Set on Some Android Devices

**Status:** Fixed
**Severity:** Medium — affects training session creation on specific Android devices
**Discovered:** 2026-04-12
**Reported by user:** ZXeNzI4inHMUg2ze9vSI0t18FSA2
**Fixed in:** (pending PR)

---

## Symptom

On some Android devices, tapping the start time field in training session creation opens the
date/time pickers correctly, but after completing the selection the start time remains "Not
selected". The same flow works on other Android devices.

---

## Root Causes

Two independent issues combine to cause this on certain devices:

### 1. `barrierDismissible: true` (default) on time-picker dialog

`showDialog` defaults to `barrierDismissible: true`, meaning a tap outside the dialog area
dismisses it without invoking the OK button. On smaller screens or devices where the dialog
does not fill the full screen width, users can accidentally tap the darkened barrier area.

When dismissed this way, the local `TimeOfDay? time` variable remains `null`. The guard
`if (time == null || !mounted) return;` causes an early return and `_selectedStartTime` is
never updated.

**Affected dialogs:** both start-time and end-time pickers in
`training_session_creation_page.dart`.

### 2. `minimumDate` with sub-minute precision in `CupertinoDatePicker`

When the user selects today as the date, `minimumDate` was set to `DateTime.now()`, which
includes seconds and milliseconds (e.g., `14:32:47.123`). The `CupertinoDatePicker` in time
mode operates at minute granularity. On certain Android versions, having sub-minute precision
in `minimumDate` causes the picker to behave inconsistently — it may refuse to accept the
initial value or silently snap the internal state in a way that prevents the OK tap from
registering the correct time.

---

## Fix

File: `lib/features/training/presentation/pages/training_session_creation_page.dart`

1. Added `barrierDismissible: false` to both `showDialog` calls (start-time and end-time
   pickers). The Cancel button already existed as the explicit dismiss path.

2. Truncated `minPickerTime` to minute precision:
   ```dart
   // Before
   final minPickerTime = isToday ? now : null;

   // After
   final minPickerTime = isToday
       ? DateTime(now.year, now.month, now.day, now.hour, now.minute)
       : null;
   ```

---

## Why Only Some Devices

- **Barrier dismissal:** More likely on smaller screens where the dialog leaves more visible
  barrier area, or on devices where touch targets are slightly offset.
- **Sub-minute `minimumDate`:** Flutter's `CupertinoDatePicker` is a native-rendered widget
  on Android. The behavior when `minimumDate` has sub-minute precision is not guaranteed to
  be consistent across Android versions and OEM skins.
