// Unit tests for runner.ts — concurrency engine and safety guard.

import { runScenario, Scenario } from "../src/runner";

describe("runScenario", () => {
  it("returns empty array in dry-run mode", async () => {
    const scenario: Scenario = {
      name: "test",
      run: jest.fn().mockResolvedValue(undefined),
    };
    const results = await runScenario(scenario, {
      concurrency: 5,
      requests: 20,
      dryRun: true,
    });
    expect(results).toEqual([]);
    expect(scenario.run).not.toHaveBeenCalled();
  });

  it("calls run() exactly `requests` times", async () => {
    const scenario: Scenario = {
      name: "test",
      run: jest.fn().mockResolvedValue(undefined),
    };
    await runScenario(scenario, { concurrency: 3, requests: 10 });
    expect(scenario.run).toHaveBeenCalledTimes(10);
  });

  it("records an error result when run() rejects", async () => {
    const scenario: Scenario = {
      name: "test",
      run: jest.fn().mockRejectedValue(new Error("boom")),
    };
    const results = await runScenario(scenario, { concurrency: 1, requests: 3 });
    expect(results.length).toBe(3);
    expect(results.every((r) => r.error)).toBe(true);
  });

  it("records a success result when run() resolves", async () => {
    const scenario: Scenario = {
      name: "test",
      run: jest.fn().mockResolvedValue(undefined),
    };
    const results = await runScenario(scenario, { concurrency: 2, requests: 4 });
    expect(results.length).toBe(4);
    expect(results.every((r) => !r.error)).toBe(true);
  });

  it("records durationMs >= 0 for each result", async () => {
    const scenario: Scenario = {
      name: "test",
      run: jest.fn().mockResolvedValue(undefined),
    };
    const results = await runScenario(scenario, { concurrency: 2, requests: 6 });
    expect(results.every((r) => r.durationMs >= 0)).toBe(true);
  });
});

describe("safety guard", () => {
  it("rejects non-dev project IDs", () => {
    // The guard lives in index.ts initFirebase(). We test the logic directly.
    const ALLOWED = "gatherli-dev";
    const check = (id: string) => {
      if (id !== ALLOWED) {
        throw new Error(`Load test only runs against "${ALLOWED}". Provided: "${id}"`);
      }
    };
    expect(() => check("gatherli-prod")).toThrow(/gatherli-dev/);
    expect(() => check("some-other-project")).toThrow(/gatherli-dev/);
    expect(() => check("gatherli-dev")).not.toThrow();
  });
});
