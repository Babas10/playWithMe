# Gatherli Load Test

Node.js CLI tool for load testing Gatherli Cloud Functions against **gatherli-dev only**.

---

## Setup

```bash
cd tools/load_test
npm install
```

Export your gatherli-dev service account key path:

```bash
export GATHERLI_DEV_SERVICE_ACCOUNT=/path/to/gatherli-dev-service-account.json
```

> **Never commit the service account key.** It is excluded by `.gitignore`.

---

## Usage

```bash
# Seed test data (idempotent — safe to run multiple times)
npx ts-node src/index.ts --seed

# Run a single scenario
npx ts-node src/index.ts --scenario getGamesForGroup --concurrency 10 --requests 100

# Run all scenarios sequentially
npx ts-node src/index.ts --all --concurrency 5 --requests 50

# Dry run — prints what would be called without executing
npx ts-node src/index.ts --all --dry-run

# Remove all load-test documents from Firestore
npx ts-node src/index.ts --cleanup
```

---

## Available scenarios

| Scenario | Function tested |
|---|---|
| `getGamesForGroup` | `getGamesForGroup` |
| `getUpcomingGamesForUser` | `getUpcomingGamesForUser` |
| `getFriends` | `getFriends` |
| `getUsersByIds` | `getUsersByIds` |
| `getHeadToHeadStats` | `getHeadToHeadStats` |
| `calculateUserRanking` | `calculateUserRanking` |
| `searchUserByEmail` | `searchUserByEmail` |

---

## Implementation note

Scenarios use the Firebase Admin SDK to execute the same Firestore queries that each Cloud Function performs. This measures the Firestore latency that the functions experience without the additional HTTP round-trip overhead of calling the function endpoint itself.

---

## Safety guards

- The script **refuses to run** if the service account key targets any project other than `gatherli-dev`.
- All seed documents are tagged with `_loadTest: true` and use `load-test-*` prefixed IDs for easy identification and cleanup.

---

## Running tests

```bash
npm test
```

Tests cover `reporter.ts` (percentile computation) and `runner.ts` (concurrency engine + safety guard).

---

## Benchmarks

See [BENCHMARKS.md](./BENCHMARKS.md) for recorded baseline results.
