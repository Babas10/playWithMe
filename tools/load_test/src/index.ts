// CLI entrypoint for the Gatherli load test tool.
// Safety: only runs against gatherli-dev. Never targets production.

import { Command } from "commander";
import * as admin from "firebase-admin";
import * as path from "path";
import * as fs from "fs";

import { execSync } from "child_process";

import { runScenario, Scenario } from "./runner";
import { computeStats, printReport } from "./reporter";
import { seedTestData, cleanupTestData } from "./seed";
import { BenchmarkSink, BenchmarkRow, buildRow } from "./bigquery";

import { makeScenario as makeGetGamesForGroup } from "./scenarios/getGamesForGroup";
import { makeScenario as makeGetUpcomingGamesForUser } from "./scenarios/getUpcomingGamesForUser";
import { makeScenario as makeGetFriends } from "./scenarios/getFriends";
import { makeScenario as makeGetUsersByIds } from "./scenarios/getUsersByIds";
import { makeScenario as makeGetHeadToHeadStats } from "./scenarios/getHeadToHeadStats";
import { makeScenario as makeCalculateUserRanking } from "./scenarios/calculateUserRanking";
import { makeScenario as makeSearchUserByEmail } from "./scenarios/searchUserByEmail";

// ─── Safety guard ────────────────────────────────────────────────────────────

const ALLOWED_PROJECT_ID = "gatherli-dev";

function initFirebase(): void {
  const keyPath = process.env.GATHERLI_DEV_SERVICE_ACCOUNT;
  if (!keyPath) {
    console.error(
      "❌  Set GATHERLI_DEV_SERVICE_ACCOUNT to the path of your service account JSON key."
    );
    process.exit(1);
  }

  const resolvedPath = path.resolve(keyPath);
  if (!fs.existsSync(resolvedPath)) {
    console.error(`❌  Service account key not found: ${resolvedPath}`);
    process.exit(1);
  }

  const serviceAccount = JSON.parse(fs.readFileSync(resolvedPath, "utf8"));
  const projectId: string = serviceAccount.project_id ?? "";

  if (projectId !== ALLOWED_PROJECT_ID) {
    throw new Error(
      `Load test only runs against "${ALLOWED_PROJECT_ID}". ` +
      `Provided key targets "${projectId}". Aborting.`
    );
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId,
  });

  console.log(`🔒 Connected to project: ${projectId}`);
}

// ─── Scenario registry ────────────────────────────────────────────────────────

function buildRegistry(): Record<string, () => Scenario> {
  return {
    getGamesForGroup: makeGetGamesForGroup,
    getUpcomingGamesForUser: makeGetUpcomingGamesForUser,
    getFriends: makeGetFriends,
    getUsersByIds: makeGetUsersByIds,
    getHeadToHeadStats: makeGetHeadToHeadStats,
    calculateUserRanking: makeCalculateUserRanking,
    searchUserByEmail: makeSearchUserByEmail,
  };
}

// ─── CLI ─────────────────────────────────────────────────────────────────────

async function main(): Promise<void> {
  const program = new Command();

  program
    .name("gatherli-load-test")
    .description("Load test CLI for Gatherli Cloud Functions (gatherli-dev only)")
    .option("--scenario <name>", "Run a single scenario by name")
    .option("--all", "Run all scenarios sequentially")
    .option("--seed", "Seed test data only, then exit")
    .option("--cleanup", "Remove all load-test documents, then exit")
    .option("--concurrency <n>", "Number of parallel workers", "5")
    .option("--requests <n>", "Total number of requests per scenario", "50")
    .option("--dry-run", "Print what would be called without executing")
    .option("--bigquery", "Insert results into BigQuery after the run")
    .option("--notes <text>", "Label for this run stored in BigQuery (e.g. 'post-migration')", "")
    .option("--dataset <name>", "BigQuery dataset name", "load_test")
    .option("--setup-bigquery", "Create the BigQuery dataset and table, then exit")
    .parse(process.argv);

  const opts = program.opts<{
    scenario?: string;
    all?: boolean;
    seed?: boolean;
    cleanup?: boolean;
    concurrency: string;
    requests: string;
    dryRun?: boolean;
    bigquery?: boolean;
    notes: string;
    dataset: string;
    setupBigquery?: boolean;
  }>();

  const concurrency = parseInt(opts.concurrency, 10);
  const requests = parseInt(opts.requests, 10);
  const dryRun = opts.dryRun ?? false;

  if (!dryRun) {
    initFirebase();
  }

  const db = !dryRun ? admin.firestore() : null;
  const keyPath = process.env.GATHERLI_DEV_SERVICE_ACCOUNT!;

  // Setup BigQuery table only
  if (opts.setupBigquery) {
    const sink = new BenchmarkSink(path.resolve(keyPath), opts.dataset, "results");
    await sink.setup();
    process.exit(0);
  }

  // Seed only
  if (opts.seed) {
    await seedTestData(db!);
    process.exit(0);
  }

  // Cleanup only
  if (opts.cleanup) {
    await cleanupTestData(db!);
    process.exit(0);
  }

  // Ensure seed data exists before running scenarios
  if (!dryRun) {
    console.log("🌱 Ensuring seed data is present...");
    await seedTestData(db!);
  }

  const registry = buildRegistry();

  const scenarioNames = opts.all
    ? Object.keys(registry)
    : opts.scenario
    ? [opts.scenario]
    : [];

  if (scenarioNames.length === 0) {
    console.error("❌  Specify --scenario <name>, --all, --seed, or --cleanup.");
    console.error(`   Available scenarios: ${Object.keys(registry).join(", ")}`);
    process.exit(1);
  }

  // Shared run metadata
  const runId = new Date().toISOString();
  const gitSha = (() => {
    try {
      return execSync("git rev-parse --short HEAD", { encoding: "utf8" }).trim();
    } catch {
      return "unknown";
    }
  })();
  const collectedRows: BenchmarkRow[] = [];

  for (const name of scenarioNames) {
    const factory = registry[name];
    if (!factory) {
      console.error(`❌  Unknown scenario: "${name}"`);
      console.error(`   Available: ${Object.keys(registry).join(", ")}`);
      process.exit(1);
    }

    const scenario = factory();
    const wallStart = Date.now();
    const results = await runScenario(scenario, { concurrency, requests, dryRun });
    const wallClockMs = Date.now() - wallStart;

    if (!dryRun) {
      const stats = computeStats(results);
      printReport(name, stats, concurrency, wallClockMs);

      if (opts.bigquery) {
        collectedRows.push(buildRow({
          runId,
          scenario: name,
          stats,
          concurrency,
          wallClockMs,
          gitSha,
          notes: opts.notes,
        }));
      }
    }
  }

  // Insert all rows in one batch after all scenarios complete
  if (opts.bigquery && collectedRows.length > 0) {
    console.log(`\n📤 Uploading ${collectedRows.length} result(s) to BigQuery...`);
    const sink = new BenchmarkSink(path.resolve(keyPath), opts.dataset, "results");
    await sink.insertRows(collectedRows);
  }
}

main().catch((err) => {
  console.error("❌  Fatal error:", err.message ?? err);
  process.exit(1);
});
