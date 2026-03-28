// Unit tests for the BigQuery benchmark sink helper
// Story 25.7: Store load test results in BigQuery

import { buildRow, BenchmarkSink } from "../src/bigquery";
import { Stats } from "../src/reporter";

// Mock @google-cloud/bigquery
jest.mock("@google-cloud/bigquery", () => {
  const mockInsert = jest.fn().mockResolvedValue([]);
  const mockTable = jest.fn(() => ({ insert: mockInsert }));
  const mockCreateTable = jest.fn().mockResolvedValue([{}]);
  const mockGetTables = jest.fn().mockResolvedValue([[{ id: "results" }]]);
  const mockDataset = jest.fn(() => ({
    getTables: mockGetTables,
    createTable: mockCreateTable,
    table: mockTable,
  }));
  const mockGetDatasets = jest.fn().mockResolvedValue([[{ id: "load_test" }]]);
  const mockCreateDataset = jest.fn().mockResolvedValue([{}]);

  return {
    BigQuery: jest.fn(() => ({
      getDatasets: mockGetDatasets,
      createDataset: mockCreateDataset,
      dataset: mockDataset,
    })),
    _mockInsert: mockInsert,
    _mockTable: mockTable,
    _mockGetTables: mockGetTables,
    _mockCreateTable: mockCreateTable,
    _mockDataset: mockDataset,
    _mockGetDatasets: mockGetDatasets,
  };
});

const bqModule = require("@google-cloud/bigquery");

const sampleStats: Stats = {
  count: 50,
  errors: 0,
  min: 300,
  max: 1200,
  p50: 500,
  p95: 900,
  p99: 1100,
  totalMs: 25000,
};

describe("buildRow", () => {
  it("maps stats and metadata to a BenchmarkRow correctly", () => {
    const row = buildRow({
      runId: "2026-03-26T12:00:00.000Z",
      scenario: "getGamesForGroup",
      stats: sampleStats,
      concurrency: 5,
      wallClockMs: 14800,
      gitSha: "abc1234",
      notes: "post-migration",
    });

    expect(row.scenario).toBe("getGamesForGroup");
    expect(row.p50_ms).toBe(500);
    expect(row.p95_ms).toBe(900);
    expect(row.p99_ms).toBe(1100);
    expect(row.min_ms).toBe(300);
    expect(row.max_ms).toBe(1200);
    expect(row.requests).toBe(50);
    expect(row.concurrency).toBe(5);
    expect(row.errors).toBe(0);
    expect(row.duration_ms).toBe(14800);
    expect(row.git_sha).toBe("abc1234");
    expect(row.notes).toBe("post-migration");
    expect(row.run_id).toBe("2026-03-26T12:00:00.000Z");
    expect(row.run_timestamp).toBe("2026-03-26T12:00:00.000Z");
  });

  it("includes error count in the row", () => {
    const statsWithErrors: Stats = { ...sampleStats, errors: 3 };
    const row = buildRow({
      runId: "2026-03-26T12:00:00.000Z",
      scenario: "getFriends",
      stats: statsWithErrors,
      concurrency: 5,
      wallClockMs: 8000,
      gitSha: "def5678",
      notes: "",
    });

    expect(row.errors).toBe(3);
  });
});

describe("BenchmarkSink", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("does not recreate an existing dataset and table during setup", async () => {
    bqModule._mockGetDatasets.mockResolvedValue([[{ id: "load_test" }]]);
    bqModule._mockGetTables.mockResolvedValue([[{ id: "results" }]]);

    const sink = new BenchmarkSink("/fake/key.json", "load_test", "results");
    await sink.setup();

    expect(bqModule._mockCreateTable).not.toHaveBeenCalled();
  });

  it("creates the table when it does not exist", async () => {
    bqModule._mockGetDatasets.mockResolvedValue([[{ id: "load_test" }]]);
    bqModule._mockGetTables.mockResolvedValue([[]]); // no tables

    const sink = new BenchmarkSink("/fake/key.json", "load_test", "results");
    await sink.setup();

    expect(bqModule._mockCreateTable).toHaveBeenCalledWith(
      "results",
      expect.objectContaining({ schema: expect.any(Array) })
    );
  });

  it("inserts rows into the correct table", async () => {
    const sink = new BenchmarkSink("/fake/key.json", "load_test", "results");
    const rows = [
      buildRow({
        runId: "2026-03-26T12:00:00.000Z",
        scenario: "getGamesForGroup",
        stats: sampleStats,
        concurrency: 5,
        wallClockMs: 14800,
        gitSha: "abc1234",
        notes: "test",
      }),
    ];

    await sink.insertRows(rows);

    expect(bqModule._mockTable).toHaveBeenCalledWith("results");
    expect(bqModule._mockInsert).toHaveBeenCalledWith(rows);
  });

  it("does nothing when inserting an empty row array", async () => {
    const sink = new BenchmarkSink("/fake/key.json", "load_test", "results");
    await sink.insertRows([]);
    expect(bqModule._mockInsert).not.toHaveBeenCalled();
  });
});
