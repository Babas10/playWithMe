# Notification Troubleshooting Guide

## Issue 1: MissingPluginException - Firebase Messaging

### Error Message
```
MissingPluginException(No implementation found for method Messaging#requestPermission on channel plugins.flutter.io/firebase_messaging)
```

### Solution Steps

#### For iOS:
```bash
# 1. Clean and reinstall pods
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..

# 2. Clean Flutter
flutter clean
flutter pub get

# 3. Rebuild
flutter run --flavor dev -t lib/main_dev.dart
```

#### For Android:
```bash
# 1. Clean build
flutter clean
cd android
./gradlew clean
cd ..

# 2. Reinstall dependencies
flutter pub get

# 3. Rebuild
flutter run --flavor dev -t lib/main_dev.dart
```

#### For Web:
Web requires additional service worker configuration (not yet implemented in this story).

---

## Issue 2: "Member Left" Notifications Not Working

### Root Cause
The `memberLeft` notification preference has a **default value of `false` (OFF)**. Admins must explicitly enable it in the notification settings.

### Solution

**Admins must enable the notification**:
1. Open the app
2. Navigate to: **Profile → Notification Settings**
3. Scroll to **Admin Notifications** section
4. Toggle **ON** the "Member Left" switch
5. Test again

### Verification Steps

#### 1. Check Notification Preferences in Firestore
```javascript
// Navigate to: Firestore Console → users/{adminUserId}
// Should see:
{
  "notificationPreferences": {
    "memberLeft": true,  // ← Must be true!
    "memberJoined": false,
    // ... other preferences
  }
}
```

#### 2. Check Cloud Function Logs
```bash
firebase functions:log --project playwithme-dev --only onMemberLeft
```

Look for:
- ✅ `"Notified admins about member {userId} leaving"`
- ⚠️ `"Admin {adminId} has disabled member left notifications"` ← This means it's OFF

---

## Issue 3: Cloud Functions Not Deployed

### Check if Functions are Deployed
```bash
firebase functions:list --project playwithme-dev
```

Expected output should include:
- `onInvitationCreated`
- `onInvitationAccepted`
- `onGameCreated`
- `onMemberJoined`
- `onMemberLeft`
- `onRoleChanged`

### Deploy Cloud Functions
```bash
# Deploy to dev environment
cd functions
npm run build
cd ..
firebase deploy --only functions --project playwithme-dev
```

---

## Issue 4: FCM Token Not Saved

### Check Token in Firestore
```javascript
// Firestore Console → users/{userId}
{
  "fcmTokens": ["token123..."],  // ← Should exist
  "lastTokenUpdate": Timestamp
}
```

### Force Token Refresh
1. Uninstall the app completely
2. Reinstall and launch
3. Accept notification permission
4. Check Firestore again

---

## Issue 5: Notification Permission Not Granted

### iOS
- Settings → [App Name] → Notifications → Enable

### Android (13+)
- Settings → Apps → [App Name] → Notifications → Enable

### In-App Check
Add this debug code temporarily:
```dart
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Notification authorization: ${settings.authorizationStatus}');
// Should print: AuthorizationStatus.authorized
```

---

## Complete Testing Workflow

### Step 1: Enable All Notifications
**User A (Admin)**:
1. Profile → Notification Settings
2. Enable "Member Joined" ✅
3. Enable "Member Left" ✅
4. Verify Firestore preferences updated

### Step 2: Verify Cloud Functions Deployed
```bash
firebase functions:list --project playwithme-dev
```

### Step 3: Test Member Left
**User B**:
1. Leave the group
2. Check Cloud Function logs:
   ```bash
   firebase functions:log --project playwithme-dev --only onMemberLeft
   ```

**User A (Admin)**:
3. Should receive notification within 1-2 seconds

### Step 4: Check Logs if No Notification

```bash
# Check all function logs
firebase functions:log --project playwithme-dev

# Look for:
# ✅ "Successfully sent notification"
# ❌ "Admin has disabled member left notifications"
# ❌ "Admin has no FCM tokens"
# ❌ "User not found"
```

---

## Common Issues & Fixes

### Issue: "No FCM tokens"
**Cause**: User hasn't launched app or denied permissions
**Fix**: Reinstall app and accept notifications

### Issue: "Admin has disabled notifications"
**Cause**: Preference is OFF by default
**Fix**: Enable in Notification Settings

### Issue: "User not found"
**Cause**: User document doesn't exist in Firestore
**Fix**: Ensure user completed registration

### Issue: "Settings can only be set once"
**Cause**: Firestore settings already configured (not an error)
**Fix**: Ignore this message - it's expected

### Issue: Plugin not found (MissingPluginException)
**Cause**: Native dependencies not linked
**Fix**:
- iOS: `cd ios && pod install`
- Android: Rebuild after `flutter clean`

---

## Debug Checklist

When testing notifications, verify:

- [ ] App has notification permission granted
- [ ] FCM token exists in Firestore (`users/{userId}/fcmTokens`)
- [ ] Notification preference is enabled in Firestore
- [ ] User is not in quiet hours
- [ ] Cloud Functions are deployed
- [ ] Cloud Function logs show successful send
- [ ] Device has internet connection
- [ ] Device can reach Firebase servers

---

## Quick Debug Commands

```bash
# Check function deployment
firebase functions:list --project playwithme-dev

# View recent logs
firebase functions:log --limit 50 --project playwithme-dev

# Deploy functions
firebase deploy --only functions --project playwithme-dev

# Test a specific function
firebase functions:log --only onMemberLeft --project playwithme-dev

# Check Firestore rules
firebase firestore:rules:get --project playwithme-dev
```

---

## Contact & Support

If issues persist after following this guide:
1. Check Cloud Function logs for detailed error messages
2. Verify Firestore data matches expected structure
3. Test on a different device to rule out device-specific issues
4. Check Firebase Console → Cloud Messaging → Delivery metrics
