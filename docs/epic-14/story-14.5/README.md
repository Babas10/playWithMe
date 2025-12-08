# Story 14.5: Weak-Link ELO Rating System

## Overview

This story implements an ELO rating system for beach volleyball players using the **Weak-Link** algorithm. The system automatically calculates and updates player ratings when a game is completed.

## Architecture

### System Components

```
┌─────────────────────┐     ┌──────────────────────┐     ┌─────────────────────┐
│   Flutter App       │     │  Firestore Trigger   │     │   User Documents    │
│   (Game Result)     │────▶│  (Python Function)   │────▶│   (ELO Ratings)     │
└─────────────────────┘     └──────────────────────┘     └─────────────────────┘
         │                           │                            │
         │                           │                            │
         ▼                           ▼                            ▼
┌─────────────────────┐     ┌──────────────────────┐     ┌─────────────────────┐
│   Game Document     │     │   ELO Calculator     │     │   Rating History    │
│   games/{gameId}    │     │   (Weak-Link)        │     │   Subcollection     │
└─────────────────────┘     └──────────────────────┘     └─────────────────────┘
```

### Data Flow

1. **Game Completion**: Flutter app updates game document with `status: "completed"` and `result.overallWinner`
2. **Trigger**: Firestore document update triggers `calculate_elo_ratings` Python function
3. **Validation**: Function validates game data (4 players, valid winner)
4. **Calculation**: ELO Calculator computes rating changes using Weak-Link algorithm
5. **Transaction**: Atomically updates all player ratings and creates history entries
6. **Idempotency**: Sets `eloCalculated: true` to prevent duplicate calculations

## ELO Algorithm

### Weak-Link Team Rating

Beach volleyball is a 2v2 sport where the weaker player often limits team performance. The Weak-Link algorithm reflects this:

```
Team Rating = 0.7 × R_min + 0.3 × R_max
```

Where:
- `R_min` = Rating of the weaker player (lower rating)
- `R_max` = Rating of the stronger player (higher rating)

This weights the weaker player at **70%** and the stronger player at **30%**.

### Expected Win Probability

Standard ELO formula for calculating expected win probability:

```
E = 1 / (1 + 10^((R_opponent - R_team) / 400))
```

A 400-point rating difference means the stronger team has a **90.9%** chance to win.

### Rating Change

```
ΔR = K × (S - E)
```

Where:
- `K` = K-factor (32)
- `S` = Actual score (1.0 for win, 0.0 for loss)
- `E` = Expected win probability

**Important**: Both players on the same team receive **identical** rating changes.

### Constants

| Constant | Value | Description |
|----------|-------|-------------|
| K-Factor | 32 | Determines rating volatility |
| Default Rating | 1600 | Starting rating for new players |

### Example Calculation

**Game Setup:**
- Team A: Player 1 (1700), Player 2 (1500)
- Team B: Player 3 (1600), Player 4 (1600)
- Result: Team A wins

**Step 1: Calculate Team Ratings**
```
Team A = 0.7 × 1500 + 0.3 × 1700 = 1050 + 510 = 1560
Team B = 0.7 × 1600 + 0.3 × 1600 = 1120 + 480 = 1600
```

**Step 2: Calculate Expected Probabilities**
```
E_A = 1 / (1 + 10^((1600 - 1560) / 400)) = 0.443 (44.3%)
E_B = 1 / (1 + 10^((1560 - 1600) / 400)) = 0.557 (55.7%)
```

**Step 3: Calculate Rating Changes**
```
ΔR_A = 32 × (1.0 - 0.443) = +17.8 (Team A won)
ΔR_B = 32 × (0.0 - 0.557) = -17.8 (Team B lost)
```

**Final Ratings:**
- Player 1: 1700 + 17.8 = 1717.8
- Player 2: 1500 + 17.8 = 1517.8
- Player 3: 1600 - 17.8 = 1582.2
- Player 4: 1600 - 17.8 = 1582.2

## Firestore Schema

### Game Document (`games/{gameId}`)

```javascript
{
  "status": "completed",        // Must be "completed" to trigger
  "teams": {
    "teamAPlayerIds": ["uid1", "uid2"],
    "teamBPlayerIds": ["uid3", "uid4"]
  },
  "result": {
    "overallWinner": "teamA"    // "teamA" or "teamB"
  },
  "eloCalculated": false,       // Idempotency flag
  "eloCalculatedAt": null       // Timestamp when calculated
}
```

### User Document (`users/{userId}`)

```javascript
{
  "eloRating": 1600.0,          // Current rating
  "eloLastUpdated": Timestamp,  // When last updated
  "eloPeak": 1650.0,            // Highest rating achieved
  "eloPeakDate": Timestamp,     // When peak was achieved
  "eloGamesPlayed": 10          // Total games counted
}
```

### Rating History Entry (`users/{userId}/ratingHistory/{entryId}`)

```javascript
{
  "gameId": "game123",
  "oldRating": 1600.0,
  "newRating": 1617.8,
  "ratingChange": 17.8,
  "opponentTeam": "John & Jane",
  "won": true,
  "timestamp": Timestamp
}
```

## Code Structure

```
functions/python/
├── main.py                 # Cloud Function entry point
├── requirements.txt        # Python dependencies
├── rating/
│   ├── __init__.py
│   ├── calculator.py       # ELO calculation logic
│   ├── handler.py          # Firestore trigger handler
│   └── models.py           # Data models
├── shared/
│   ├── __init__.py
│   └── logging_config.py   # Structured logging
└── tests/
    ├── __init__.py
    ├── test_calculator.py  # Calculator unit tests
    └── test_handler.py     # Handler unit tests
```

## Testing

### Running Unit Tests

```bash
# Navigate to Python functions directory
cd functions/python

# Activate virtual environment
source venv/bin/activate

# Run all tests
python -m pytest tests/ -v

# Run with coverage
python -m pytest tests/ --cov=rating --cov-report=term-missing
```

### Test Coverage

The implementation includes **50 unit tests** covering:

- **Calculator Tests** (21 tests):
  - Team rating calculations
  - Expected win probability
  - Rating change calculations
  - Edge cases and validation

- **Handler Tests** (29 tests):
  - Game data parsing
  - Idempotency protection
  - Status filtering
  - Error handling

### Integration Testing

For end-to-end testing with Firebase Emulator, see the TypeScript integration tests in `functions/test/integration/eloCalculation.test.ts`.

## Key Design Decisions

### Why Weak-Link?

In beach volleyball, team success is highly dependent on both players performing well. Unlike larger team sports where a star player can carry the team, beach volleyball's 2v2 format means:

1. Every point involves both players
2. The opponent often targets the weaker player
3. Defense gaps from one player affect the whole team

The Weak-Link algorithm (70% weight on the weaker player) better reflects this reality than simple averaging.

### Why Server-Side Calculation?

ELO calculations happen in a Cloud Function rather than the Flutter client because:

1. **Security**: Prevents client-side manipulation of ratings
2. **Consistency**: Same calculation applied regardless of client version
3. **Atomicity**: Firestore transactions ensure all-or-nothing updates
4. **Auditability**: Server logs provide a clear audit trail

### Why Python?

Python was chosen for the ELO function because:

1. **Numerical computation**: Python excels at mathematical operations
2. **Testing**: pytest provides excellent testing infrastructure
3. **Readability**: Algorithm implementation is clear and maintainable
4. **Firebase support**: Full support in firebase-functions-python

## Related Stories

- **Story 14.5.1**: Python Environment Setup + ELO Calculator
- **Story 14.5.2**: Firestore Trigger Handler + Transaction Logic
- **Story 14.5.3**: Flutter Model Updates + Rating History
- **Story 14.5.4**: Multi-Environment Deployment + Verification

## References

- [ELO Rating System (Wikipedia)](https://en.wikipedia.org/wiki/Elo_rating_system)
- [Firebase Cloud Functions - Python](https://firebase.google.com/docs/functions/get-started?gen=2nd#python)
- [Firestore Transactions](https://firebase.google.com/docs/firestore/manage-data/transactions)
