# ELO Rating System - Deployment Guide

## Overview

This document covers deployment, verification, monitoring, and rollback procedures for the `calculate_elo_ratings` Python Cloud Function.

## Prerequisites

- Firebase CLI installed (`npm install -g firebase-tools`)
- Python 3.11+ installed locally
- Firebase project access for all environments
- Authenticated with Firebase CLI (`firebase login`)

## Environment Setup

### Local Python Environment

```bash
# Navigate to Python functions directory
cd functions/python

# Create virtual environment (if not exists)
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Verify Dependencies

```bash
pip list | grep -E "firebase|pydantic|pytest"
# Expected output:
# firebase-admin    6.3.0
# firebase-functions 0.4.0
# pydantic          2.10.4
# pytest            8.3.4
```

## Deployment Commands

### Development Environment

```bash
# Deploy Python functions to dev
firebase deploy --only functions:python-functions --project playwithme-dev

# View deployment logs
firebase functions:log --project playwithme-dev
```

### Staging Environment

```bash
# Deploy Python functions to staging
firebase deploy --only functions:python-functions --project playwithme-stg

# View deployment logs
firebase functions:log --project playwithme-stg
```

### Production Environment

```bash
# Deploy Python functions to production
firebase deploy --only functions:python-functions --project playwithme-prod

# View deployment logs
firebase functions:log --project playwithme-prod
```

### Deploy All Functions (TypeScript + Python)

```bash
# Deploy all functions to a specific environment
firebase deploy --only functions --project playwithme-dev
```

## Pre-Deployment Checklist

- [ ] All Python unit tests pass (`pytest tests/ -v`)
- [ ] Code reviewed and approved
- [ ] Test coverage meets minimum threshold (90%+)
- [ ] No hardcoded secrets or API keys
- [ ] Requirements.txt is up to date
- [ ] Virtual environment excluded in firebase.json ignore

## Verification Steps

### 1. Verify Deployment

```bash
# List deployed functions
firebase functions:list --project playwithme-dev

# Expected output shows:
# calculate_elo_ratings | v2 | google.cloud.firestore.document.v1.updated | us-central1 | 256 | python311
```

### 2. Check Function Status in Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select the appropriate project (dev/stg/prod)
3. Navigate to Functions
4. Verify `calculate_elo_ratings` is listed as Active

### 3. Test ELO Calculation (Dev/Staging)

**Option A: Via Flutter App**

1. Create a game with 4 players
2. Complete the game with a result
3. Check player ratings updated in Firestore

**Option B: Via Firebase Console**

1. Open Firestore Console
2. Create/update a test game document:
   ```json
   {
     "status": "completed",
     "teams": {
       "teamAPlayerIds": ["user1", "user2"],
       "teamBPlayerIds": ["user3", "user4"]
     },
     "result": {
       "overallWinner": "teamA"
     },
     "eloCalculated": false
   }
   ```
3. Verify the function triggers by checking:
   - `eloCalculated` becomes `true`
   - User documents have updated `eloRating` fields
   - Rating history entries created

### 4. Verify Idempotency

1. Manually update the same game document again
2. Verify ratings don't change (function should skip)
3. Check logs show "already_calculated" reason

### 5. Monitor Logs

```bash
# Watch live logs
firebase functions:log --project playwithme-dev --follow

# Filter by function name
firebase functions:log --project playwithme-dev --only calculate_elo_ratings
```

## Monitoring

### Key Metrics to Watch

| Metric | Healthy Range | Action if Exceeded |
|--------|---------------|-------------------|
| Error Rate | < 0.1% | Check logs, investigate errors |
| Execution Time | < 3 seconds | Optimize transaction logic |
| Timeout Rate | 0% | Increase timeout or optimize |
| Invocation Count | Varies | Compare with expected game volume |

### Setting Up Alerts

1. Go to Google Cloud Console > Monitoring
2. Create alerting policy for:
   - Error rate > 1%
   - 95th percentile latency > 5s
   - Function timeout errors

### Log Queries

```bash
# Find errors
firebase functions:log --project playwithme-prod | grep -i error

# Find specific game
firebase functions:log --project playwithme-prod | grep "game_id.*YOUR_GAME_ID"

# Count executions
firebase functions:log --project playwithme-prod | grep "ELO calculation completed" | wc -l
```

## Rollback Procedures

### Option 1: Delete Function

```bash
# Remove function from environment
firebase functions:delete calculate_elo_ratings --project playwithme-prod

# Confirm deletion when prompted
```

**Note**: Deleting the function means ELO ratings won't update until redeployed. Games with `eloCalculated: false` will be processed once the function is restored.

### Option 2: Redeploy Previous Version

```bash
# Find previous working commit
git log --oneline functions/python/

# Checkout previous version
git checkout <previous-commit> -- functions/python/

# Redeploy
firebase deploy --only functions:python-functions --project playwithme-prod

# After fixing, restore current code
git checkout HEAD -- functions/python/
```

### Option 3: Disable Trigger (Emergency)

If you need to stop processing without deleting:

1. Go to Firebase Console > Functions
2. Click on `calculate_elo_ratings`
3. Click "Disable" (if available) or set a resource limit

### Recovery After Rollback

Games that weren't processed during downtime will have `eloCalculated: false`. After deploying a fix:

1. The next update to those games will trigger calculation
2. Or manually update the game documents to trigger reprocessing

## Troubleshooting

### Common Issues

#### Function Not Triggering

**Symptoms**: Game completed but ratings don't update

**Checks**:
1. Verify function is deployed: `firebase functions:list`
2. Check game document has `status: "completed"`
3. Check game has valid `teams` and `result` fields
4. Check `eloCalculated` is not already `true`

**Solution**: Check function logs for errors

#### Transaction Failures

**Symptoms**: Logs show transaction errors

**Possible Causes**:
- Concurrent updates to same user document
- User document doesn't exist

**Solution**: The function retries automatically. If persistent, check user documents exist.

#### Incorrect Calculations

**Symptoms**: Ratings don't match expected values

**Checks**:
1. Verify team composition in game document
2. Check current ratings before calculation
3. Manually calculate expected result using algorithm

**Solution**: Run unit tests to verify algorithm is correct

#### Timeout Errors

**Symptoms**: Function times out (> 60 seconds)

**Possible Causes**:
- Firestore cold start
- Network issues
- Too many reads in transaction

**Solution**:
- Check if issue is consistent or intermittent
- Consider increasing timeout if needed
- Optimize transaction reads

### Log Analysis

**Successful Execution Pattern**:
```
INFO: Game document updated, checking for ELO calculation
INFO: Starting ELO calculation
INFO: Calculated ratings
INFO: Updated player rating (x4)
INFO: ELO calculation completed successfully
```

**Skipped Execution Pattern**:
```
INFO: Game document updated, checking for ELO calculation
INFO: Game already has ELO calculated, skipping
INFO: ELO calculation handler completed
```

**Error Pattern**:
```
INFO: Game document updated, checking for ELO calculation
ERROR: Invalid game data: Team A must have exactly 2 players
```

## Performance Benchmarks

| Operation | Expected Duration |
|-----------|------------------|
| Cold start | 1-3 seconds |
| Warm execution | < 500ms |
| Full transaction | < 2 seconds |
| Total execution | < 5 seconds |

## Security Considerations

1. **No Direct Access**: Function uses Admin SDK, bypasses security rules
2. **Audit Trail**: All calculations logged with game_id and player_ids
3. **Idempotency**: Prevents double-processing via `eloCalculated` flag
4. **Atomic Updates**: Transactions prevent partial updates

## Contact

For issues with the ELO system:
1. Check this troubleshooting guide
2. Review function logs
3. Open a GitHub issue with relevant logs
