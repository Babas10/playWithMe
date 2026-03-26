// Unit tests for reporter.ts — p50/p95/p99 percentile computation.

import { computeStats, printReport, Result } from "../src/reporter";

describe("computeStats", () => {
  it("returns zeroes for empty input", () => {
    const stats = computeStats([]);
    expect(stats).toEqual({
      count: 0, errors: 0, min: 0, max: 0,
      p50: 0, p95: 0, p99: 0, totalMs: 0,
    });
  });

  it("handles a single result", () => {
    const stats = computeStats([{ durationMs: 100, error: false }]);
    expect(stats.count).toBe(1);
    expect(stats.min).toBe(100);
    expect(stats.max).toBe(100);
    expect(stats.p50).toBe(100);
    expect(stats.p95).toBe(100);
    expect(stats.p99).toBe(100);
    expect(stats.errors).toBe(0);
  });

  it("computes correct percentiles for sorted input", () => {
    // 10 values: 10, 20, 30, ..., 100
    const results: Result[] = Array.from({ length: 10 }, (_, i) => ({
      durationMs: (i + 1) * 10,
      error: false,
    }));
    const stats = computeStats(results);
    expect(stats.min).toBe(10);
    expect(stats.max).toBe(100);
    expect(stats.p50).toBe(50);
    expect(stats.p95).toBe(100);
    expect(stats.p99).toBe(100);
    expect(stats.errors).toBe(0);
  });

  it("computes correct percentiles for unsorted input", () => {
    const results: Result[] = [
      { durationMs: 300, error: false },
      { durationMs: 100, error: false },
      { durationMs: 200, error: false },
      { durationMs: 50, error: false },
      { durationMs: 150, error: false },
    ];
    const stats = computeStats(results);
    expect(stats.min).toBe(50);
    expect(stats.max).toBe(300);
    // sorted: [50, 100, 150, 200, 300] — p50 = index ceil(2.5)-1 = 2 → 150
    expect(stats.p50).toBe(150);
  });

  it("counts errors correctly", () => {
    const results: Result[] = [
      { durationMs: 100, error: false },
      { durationMs: 200, error: true },
      { durationMs: 150, error: true },
    ];
    const stats = computeStats(results);
    expect(stats.errors).toBe(2);
    expect(stats.count).toBe(3);
  });

  it("computes totalMs as sum of all durations", () => {
    const results: Result[] = [
      { durationMs: 100, error: false },
      { durationMs: 200, error: false },
      { durationMs: 300, error: false },
    ];
    const stats = computeStats(results);
    expect(stats.totalMs).toBe(600);
  });

  it("handles 100 values with known p95", () => {
    // 100 values: 1, 2, ..., 100
    const results: Result[] = Array.from({ length: 100 }, (_, i) => ({
      durationMs: i + 1,
      error: false,
    }));
    const stats = computeStats(results);
    expect(stats.p50).toBe(50);
    expect(stats.p95).toBe(95);
    expect(stats.p99).toBe(99);
    expect(stats.min).toBe(1);
    expect(stats.max).toBe(100);
  });
});

describe("printReport", () => {
  it("prints without throwing", () => {
    const stats = computeStats(
      Array.from({ length: 10 }, (_, i) => ({ durationMs: (i + 1) * 10, error: false }))
    );
    expect(() => printReport("getGamesForGroup", stats, 5, 4200)).not.toThrow();
  });
});
