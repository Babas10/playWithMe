// Unit Test: onEloCalculationComplete Cloud Function
// Story 301.8: Decoupled Head-to-Head Stats Processing

// NOTE: This is a simplified unit test focusing on trigger logic.
// Full end-to-end behavior is tested in:
// - test/integration/decoupledArchitecture.test.ts
// - test/integration/performanceTiming.test.ts

describe("onEloCalculationComplete", () => {
  it("should be exported from headToHeadGameUpdates", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    expect(onEloCalculationComplete).toBeDefined();
    expect(typeof onEloCalculationComplete).toBe("object");
  });

  it("should be a Cloud Function", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    // Verify it's a Cloud Function (has __trigger property)
    expect(onEloCalculationComplete.__trigger).toBeDefined();
    expect(onEloCalculationComplete.__trigger.eventTrigger).toBeDefined();
  });

  it("should have correct trigger configuration", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    const trigger = onEloCalculationComplete.__trigger;

    expect(trigger.eventTrigger.resource).toContain("games/{gameId}");
    expect(trigger.eventTrigger.eventType).toContain("update");
  });

  it("should have 180 second timeout", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    expect(onEloCalculationComplete.__trigger.timeoutSeconds).toBe(180);
  });

  it("should have 512MB memory allocation", () => {
    const { onEloCalculationComplete } = require("../../src/headToHeadGameUpdates");
    expect(onEloCalculationComplete.__trigger.availableMemoryMb).toBe(512);
  });
});
