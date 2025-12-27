// Unit Test: onEloCalculationComplete Cloud Function
// Story 301.8: Decoupled Head-to-Head Stats Processing

// NOTE: This is a simplified unit test focusing on module exports.
// Full end-to-end behavior is tested in:
// - test/integration/decoupledArchitecture.test.ts
// - test/integration/performanceTiming.test.ts

describe("onEloCalculationComplete", () => {
  it("should be exported from headToHeadGameUpdates", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    expect(onEloCalculationComplete).toBeDefined();
    expect(typeof onEloCalculationComplete).toBe("function");
  });

  it("should be exported in index.ts", () => {
    const index = require("../../src/index");
    expect(index.onEloCalculationComplete).toBeDefined();
  });
});
