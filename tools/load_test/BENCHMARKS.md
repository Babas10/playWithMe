# Load Test Benchmarks — gatherli-dev

Baseline benchmarks are recorded here after each significant infrastructure change.
Run the tool against gatherli-dev and paste the output below.

---

## How to run

```bash
cd tools/load_test
export GATHERLI_DEV_SERVICE_ACCOUNT=/path/to/gatherli-dev-service-account.json
npx ts-node src/index.ts --all --concurrency 5 --requests 50
```

---

## Baseline — to be recorded

Run the load test after Story 25.2 is deployed and paste results here.

```
# Example format:

📊 Load Test Report — getGamesForGroup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Requests:     50
Concurrency:  5
Duration:     x.xs

Latency (ms)
  p50:   ???
  p95:   ???
  p99:   ???
  min:   ???
  max:   ???

Errors:  0 / 50 (0%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
