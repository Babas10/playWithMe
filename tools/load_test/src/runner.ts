// Concurrency engine: dispatches parallel workers and collects timing results.

import { Result } from "./reporter";

export interface Scenario {
  name: string;
  /** Called once per request. Must resolve (success) or reject (error). */
  run: () => Promise<void>;
}

export interface RunOptions {
  concurrency: number;
  requests: number;
  dryRun?: boolean;
}

/**
 * Runs a scenario with the given concurrency level.
 * Divides `requests` evenly across `concurrency` workers.
 * Each worker runs its share of requests sequentially to control load.
 */
export async function runScenario(
  scenario: Scenario,
  options: RunOptions
): Promise<Result[]> {
  const { concurrency, requests, dryRun } = options;

  if (dryRun) {
    console.log(
      `[dry-run] Would call "${scenario.name}" ${requests}x at concurrency ${concurrency}`
    );
    return [];
  }

  const perWorker = Math.ceil(requests / concurrency);
  const allResults: Result[] = [];

  const workers = Array.from({ length: concurrency }, async (_, workerIdx) => {
    const count = workerIdx < concurrency - 1
      ? perWorker
      : requests - perWorker * (concurrency - 1); // last worker takes remainder

    const results: Result[] = [];
    for (let i = 0; i < count; i++) {
      const start = Date.now();
      let error = false;
      try {
        await scenario.run();
      } catch {
        error = true;
      }
      results.push({ durationMs: Date.now() - start, error });
    }
    return results;
  });

  const workerResults = await Promise.all(workers);
  for (const r of workerResults) allResults.push(...r);
  return allResults;
}
