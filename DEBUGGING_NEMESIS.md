# Debugging Nemesis Feature

## Step 1: Run the Diagnostic Script

```bash
cd functions
node scripts/checkNemesis.js
```

This will check:
1. ✅ If nemesis field exists in user document
2. ✅ If head-to-head records exist
3. ✅ If games are completed and ELO calculated

## Step 2: Common Issues & Solutions

### Issue 1: No Nemesis Field in User Document

**Symptom:** `checkNemesis.js` shows "❌ No nemesis field found"

**Cause:** Cloud Function `updateNemesis()` not running

**Solutions:**

#### A. Check if ELO Cloud Function is running
The nemesis update is triggered AFTER the ELO calculation. Check if games have `eloCalculated = true`:

```javascript
// In Firebase Console > Firestore > games collection
// Check a completed game:
{
  status: "completed",
  eloCalculated: true  // ← This should be true
}
```

If `eloCalculated = false`, the ELO Cloud Function hasn't run yet. This could be because:
- Cloud Functions are not deployed
- The trigger isn't working
- There's an error in the Cloud Function

#### B. Manually trigger the ELO calculation
If games are stuck with `eloCalculated = false`, you can manually trigger it by updating a game:

```bash
# In Firestore console, update a game document:
# Change: eloCalculated: false → true (then back to false)
# This will trigger the onGameResultSubmitted Cloud Function
```

#### C. Check Cloud Function deployment
```bash
firebase use playwithme-dev
firebase functions:list | grep onGameResultSubmitted
```

Should show: `onGameResultSubmitted(us-central1): Successful update operation`

### Issue 2: No Head-to-Head Records

**Symptom:** `checkNemesis.js` shows "❌ No head-to-head records found"

**Cause:** `updateHeadToHeadStats()` not running or games don't have opposing teams

**Solutions:**

#### A. Check game structure
Games must have `teams` with opposing players:

```javascript
{
  teams: {
    teamAPlayerIds: ["user1", "user2"],
    teamBPlayerIds: ["user3", "user4"]  // user3 and user4 are opponents of user1
  }
}
```

#### B. Check if processStatsTracking is being called
Look at Cloud Function logs:

```bash
firebase functions:log --limit 100 | grep "Successfully processed teammate and head-to-head"
```

### Issue 3: Head-to-Head Records Exist But No Nemesis

**Symptom:** H2H records exist but nemesis is still null

**Cause:** Not enough games against a single opponent (need ≥3 games)

**Solutions:**

#### A. Check matchup counts
In `checkNemesis.js` output, verify opponent has ≥3 games:

```
Opponent: user3-id
  Games: 5 (1W - 4L)  // ← This should trigger nemesis
  Win Rate: 20.0%
```

If all opponents have < 3 games, nemesis will be null (this is expected behavior).

#### B. Force nemesis recalculation
You can manually call `updateNemesis()` for a user:

Create a one-time script:
```javascript
// functions/scripts/forceNemesisUpdate.js
const admin = require('firebase-admin');
const { updateNemesis } = require('../lib/statsTracking');

admin.initializeApp({ projectId: "playwithme-dev" });

async function run() {
  const userId = "I1rVhwkQTyXL1iyBLSDNQPPiFnY2";
  const db = admin.firestore();

  await db.runTransaction(async (transaction) => {
    await updateNemesis(transaction, userId);
  });

  console.log("✅ Nemesis updated!");
}

run().then(() => process.exit(0));
```

Run it:
```bash
cd functions
npm run build
node scripts/forceNemesisUpdate.js
```

### Issue 4: UI Shows Empty State Despite Nemesis Existing

**Symptom:** Nemesis exists in Firestore but UI shows "No Nemesis Yet"

**Cause:** UI not reading user document correctly or cache issue

**Solutions:**

#### A. Check Firestore directly
Go to Firebase Console > Firestore > users > [your-user-id]

Verify `nemesis` field exists:
```json
{
  "nemesis": {
    "opponentId": "user3-id",
    "opponentName": "John Doe",
    "gamesLost": 5,
    "gamesWon": 1,
    "gamesPlayed": 6,
    "winRate": 16.666666666666668
  }
}
```

#### B. Force app refresh
- Kill the app completely
- Clear app data/cache
- Restart the app
- Navigate to profile

#### C. Check RivalsCard is reading correctly
Add debug logging to `rivals_card.dart`:

```dart
@override
Widget build(BuildContext context) {
  final nemesis = user.nemesis;
  print("🔍 DEBUG: Nemesis data: $nemesis");  // ← Add this
  // ... rest of code
}
```

## Step 3: Verify Everything is Working

### Checklist:

- [ ] Cloud Functions deployed to dev environment
- [ ] Games have `status: "completed"`
- [ ] Games have `eloCalculated: true`
- [ ] User has `headToHead` subcollection with entries
- [ ] At least one opponent has ≥3 games
- [ ] User document has `nemesis` field
- [ ] UI shows nemesis (not empty state)

## Step 4: Check Firebase Console Logs

```bash
# Real-time logs (keep this running while creating games)
firebase functions:log --only typescript-functions

# Look for:
# - "Updated nemesis for [userId]: [opponentName]"
# - "Successfully processed teammate and head-to-head stats"
```

## Need Help?

If none of the above works, run these commands and share the output:

```bash
# 1. Check nemesis data
cd functions
node scripts/checkNemesis.js > nemesis-debug.txt

# 2. Check Cloud Function logs
firebase functions:log --limit 100 > function-logs.txt

# 3. List deployed functions
firebase functions:list > deployed-functions.txt
```

Then check these files for clues.
