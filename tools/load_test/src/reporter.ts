// Latency statistics and report formatting for load test results.

export interface Result {
  durationMs: number;
  error: boolean;
}

export interface Stats {
  count: number;
  errors: number;
  min: number;
  max: number;
  p50: number;
  p95: number;
  p99: number;
  totalMs: number;
}

export function computeStats(results: Result[]): Stats {
  if (results.length === 0) {
    return { count: 0, errors: 0, min: 0, max: 0, p50: 0, p95: 0, p99: 0, totalMs: 0 };
  }

  const errors = results.filter((r) => r.error).length;
  const durations = results.map((r) => r.durationMs).sort((a, b) => a - b);

  const percentile = (p: number): number => {
    const idx = Math.ceil((p / 100) * durations.length) - 1;
    return durations[Math.max(0, idx)];
  };

  return {
    count: results.length,
    errors,
    min: durations[0],
    max: durations[durations.length - 1],
    p50: percentile(50),
    p95: percentile(95),
    p99: percentile(99),
    totalMs: durations.reduce((sum, d) => sum + d, 0),
  };
}

export function printReport(
  scenarioName: string,
  stats: Stats,
  concurrency: number,
  wallClockMs: number
): void {
  const bar = "━".repeat(45);
  const errorRate = stats.count > 0
    ? ((stats.errors / stats.count) * 100).toFixed(1)
    : "0.0";

  console.log(`\n📊 Load Test Report — ${scenarioName}`);
  console.log(bar);
  console.log(`Requests:     ${stats.count}`);
  console.log(`Concurrency:  ${concurrency}`);
  console.log(`Duration:     ${(wallClockMs / 1000).toFixed(1)}s`);
  console.log(`\nLatency (ms)`);
  console.log(`  p50:   ${stats.p50}`);
  console.log(`  p95:   ${stats.p95}`);
  console.log(`  p99:   ${stats.p99}`);
  console.log(`  min:   ${stats.min}`);
  console.log(`  max:   ${stats.max}`);
  console.log(`\nErrors:  ${stats.errors} / ${stats.count} (${errorRate}%)`);
  console.log(bar);
}
