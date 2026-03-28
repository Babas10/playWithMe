# Load Test Benchmarks — gatherli-dev

Baseline benchmarks are recorded here after each significant infrastructure change.
Run the tool against gatherli-dev and paste the output below.

> **Note:** The load test replicates Cloud Function Firestore queries directly via the
> Admin SDK. It measures Firestore read latency from the local machine, not end-to-end
> Cloud Function latency. Function region migrations (e.g. Story 25.4) improve the
> function-to-Firestore hop experienced by real users but will not be fully visible here.

---

## How to run

```bash
cd tools/load_test
export GATHERLI_DEV_SERVICE_ACCOUNT=/path/to/gatherli-dev-service-account.json

# Run and print results to console only
npx ts-node src/index.ts --all --concurrency 5 --requests 50

# Run and also store results in BigQuery (first time: create the table)
npx ts-node src/index.ts --setup-bigquery
npx ts-node src/index.ts --all --concurrency 5 --requests 50 --bigquery --notes "post-migration"
```

Results land in BigQuery table `load_test.results` in the `gatherli-dev` project.
Use `--dataset <name>` to override the dataset name (default: `load_test`).
The service account must have the **BigQuery Data Editor** role on the dataset.

---

## Baseline — functions in us-central1 (Story 25.2, 2026-03-26)

```
📊 Load Test Report — getGamesForGroup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     15.6s

Latency (ms)
  p50:   1031
  p95:   3356
  p99:   3371
  min:   630
  max:   3371

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getUpcomingGamesForUser
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     9.1s

Latency (ms)
  p50:   844
  p95:   1057
  p99:   1192
  min:   643
  max:   1192

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getFriends
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     8.6s

Latency (ms)
  p50:   845
  p95:   1106
  p99:   1168
  min:   642
  max:   1168

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getUsersByIds
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     5.1s

Latency (ms)
  p50:   447
  p95:   633
  p99:   782
  min:   311
  max:   782

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getHeadToHeadStats
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     4.5s

Latency (ms)
  p50:   379
  p95:   648
  p99:   657
  min:   300
  max:   657

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — calculateUserRanking
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     9.1s

Latency (ms)
  p50:   872
  p95:   1159
  p99:   1242
  min:   699
  max:   1242

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — searchUserByEmail
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     3.8s

Latency (ms)
  p50:   317
  p95:   554
  p99:   570
  min:   301
  max:   570

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Post-migration — functions in europe-west6 (Story 25.4, 2026-03-26)

| Function | p50 Δ | p95 Δ | Notes |
|---|---|---|---|
| `getGamesForGroup` | 1031 → 1109ms (+78) | 3356 → 3043ms (-313) | p95 spike persists — see Story 25.5 |
| `getUpcomingGamesForUser` | 844 → 828ms (-16) | 1057 → 1176ms (+119) | within noise |
| `getFriends` | 845 → 793ms (-52) | 1106 → 1084ms (-22) | slight improvement |
| `getUsersByIds` | 447 → 389ms (-58) | 633 → 649ms (+16) | slight improvement |
| `getHeadToHeadStats` | 379 → 378ms (-1) | 648 → 575ms (-73) | p95 improved |
| `calculateUserRanking` | 872 → 748ms (-124) | 1159 → 885ms (-274) | **best improvement** |
| `searchUserByEmail` | 317 → 339ms (+22) | 554 → 552ms (-2) | within noise |

```
📊 Load Test Report — getGamesForGroup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     14.7s

Latency (ms)
  p50:   1109
  p95:   3043
  p99:   3062
  min:   626
  max:   3062

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getUpcomingGamesForUser
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     9.2s

Latency (ms)
  p50:   828
  p95:   1176
  p99:   1336
  min:   632
  max:   1336

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getFriends
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     8.2s

Latency (ms)
  p50:   793
  p95:   1084
  p99:   1160
  min:   626
  max:   1160

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getUsersByIds
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     4.9s

Latency (ms)
  p50:   389
  p95:   649
  p99:   830
  min:   313
  max:   830

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — getHeadToHeadStats
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     4.6s

Latency (ms)
  p50:   378
  p95:   575
  p99:   576
  min:   296
  max:   576

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — calculateUserRanking
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     7.9s

Latency (ms)
  p50:   748
  p95:   885
  p99:   941
  min:   678
  max:   941

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Load Test Report — searchUserByEmail
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     3.9s

Latency (ms)
  p50:   339
  p95:   552
  p99:   647
  min:   300
  max:   647

Errors:  0 / 50 (0.0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
