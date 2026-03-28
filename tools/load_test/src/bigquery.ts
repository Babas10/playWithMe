// BigQuery sink for load test results.
// Inserts one row per scenario after a run when --bigquery flag is passed.

import { BigQuery } from "@google-cloud/bigquery";
import { Stats } from "./reporter";

export interface BenchmarkRow {
  run_id: string;
  run_timestamp: string; // ISO string — BigQuery TIMESTAMP
  scenario: string;
  p50_ms: number;
  p95_ms: number;
  p99_ms: number;
  min_ms: number;
  max_ms: number;
  requests: number;
  concurrency: number;
  errors: number;
  duration_ms: number;
  git_sha: string;
  notes: string;
}

const TABLE_SCHEMA = [
  { name: "run_id",         type: "STRING" },
  { name: "run_timestamp",  type: "TIMESTAMP" },
  { name: "scenario",       type: "STRING" },
  { name: "p50_ms",         type: "INT64" },
  { name: "p95_ms",         type: "INT64" },
  { name: "p99_ms",         type: "INT64" },
  { name: "min_ms",         type: "INT64" },
  { name: "max_ms",         type: "INT64" },
  { name: "requests",       type: "INT64" },
  { name: "concurrency",    type: "INT64" },
  { name: "errors",         type: "INT64" },
  { name: "duration_ms",    type: "INT64" },
  { name: "git_sha",        type: "STRING" },
  { name: "notes",          type: "STRING" },
];

export class BenchmarkSink {
  private bq: BigQuery;
  private datasetId: string;
  private tableId: string;

  constructor(keyFilename: string, datasetId: string, tableId: string) {
    this.bq = new BigQuery({ keyFilename });
    this.datasetId = datasetId;
    this.tableId = tableId;
  }

  /** Create the dataset and table if they do not already exist. */
  async setup(): Promise<void> {
    const [datasets] = await this.bq.getDatasets();
    const datasetExists = datasets.some((d) => d.id === this.datasetId);

    if (!datasetExists) {
      await this.bq.createDataset(this.datasetId, { location: "EU" });
      console.log(`✅ BigQuery dataset created: ${this.datasetId}`);
    }

    const dataset = this.bq.dataset(this.datasetId);
    const [tables] = await dataset.getTables();
    const tableExists = tables.some((t) => t.id === this.tableId);

    if (!tableExists) {
      await dataset.createTable(this.tableId, { schema: TABLE_SCHEMA });
      console.log(`✅ BigQuery table created: ${this.datasetId}.${this.tableId}`);
    } else {
      console.log(`ℹ️  BigQuery table already exists: ${this.datasetId}.${this.tableId}`);
    }
  }

  /** Insert a batch of rows (one per scenario). */
  async insertRows(rows: BenchmarkRow[]): Promise<void> {
    if (rows.length === 0) return;
    await this.bq
      .dataset(this.datasetId)
      .table(this.tableId)
      .insert(rows);
    console.log(`📤 Inserted ${rows.length} row(s) into BigQuery (${this.datasetId}.${this.tableId})`);
  }
}

/** Build a BenchmarkRow from a completed scenario's stats. */
export function buildRow(params: {
  runId: string;
  scenario: string;
  stats: Stats;
  concurrency: number;
  wallClockMs: number;
  gitSha: string;
  notes: string;
}): BenchmarkRow {
  return {
    run_id:        params.runId,
    run_timestamp: new Date(params.runId).toISOString(),
    scenario:      params.scenario,
    p50_ms:        params.stats.p50,
    p95_ms:        params.stats.p95,
    p99_ms:        params.stats.p99,
    min_ms:        params.stats.min,
    max_ms:        params.stats.max,
    requests:      params.stats.count,
    concurrency:   params.concurrency,
    errors:        params.stats.errors,
    duration_ms:   params.wallClockMs,
    git_sha:       params.gitSha,
    notes:         params.notes,
  };
}
