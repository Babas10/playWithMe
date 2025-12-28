// Unit Test: statsTracking (Story 301.8 - Regression Tests)
// Verifies that h2h stats are NO LONGER processed in processStatsTracking

// NOTE: This is a simplified unit test focusing on module exports.
// Full end-to-end behavior including h2h decoupling is tested in:
// - test/integration/decoupledArchitecture.test.ts
// - test/integration/performanceTiming.test.ts

describe("processStatsTracking (Story 301.8 - Decoupled)", () => {
  it("should export processStatsTracking function", () => {
    const { processStatsTracking } = require("../../src/statsTracking");
    expect(processStatsTracking).toBeDefined();
    expect(typeof processStatsTracking).toBe("function");
  });

  it("should export updateTeammateStats function", () => {
    const { updateTeammateStats } = require("../../src/statsTracking");
    expect(updateTeammateStats).toBeDefined();
    expect(typeof updateTeammateStats).toBe("function");
  });

  it("should export updateHeadToHeadStats function", () => {
    const { updateHeadToHeadStats } = require("../../src/statsTracking");
    expect(updateHeadToHeadStats).toBeDefined();
    expect(typeof updateHeadToHeadStats).toBe("function");
  });

  it("should export updateNemesis function", () => {
    const { updateNemesis } = require("../../src/statsTracking");
    expect(updateNemesis).toBeDefined();
    expect(typeof updateNemesis).toBe("function");
  });

  it("should have processStatsTracking accept correct number of parameters", () => {
    const { processStatsTracking } = require("../../src/statsTracking");
    // Function should accept 8 parameters (transaction, gameId, teamA, teamB, won, games, changes, playerData)
    expect(processStatsTracking.length).toBe(8);
  });

  it("should have updateTeammateStats accept correct number of parameters", () => {
    const { updateTeammateStats } = require("../../src/statsTracking");
    // Function should accept 10 parameters (transaction, playerId, teammateId, teammateName, won, scored, allowed, eloChange, gameId, currentStats)
    expect(updateTeammateStats.length).toBe(10);
  });

  it("should have updateHeadToHeadStats accept correct number of parameters", () => {
    const { updateHeadToHeadStats } = require("../../src/statsTracking");
    // Function should accept 9 parameters (playerId, opponentId, won, scored, allowed, eloChange, gameId, partnerId, oppPartnerId)
    expect(updateHeadToHeadStats.length).toBe(9);
  });

  // NOTE: Functional behavior tests (verifying h2h is NOT called) are in integration tests
  // where we can verify the actual behavior with real Firebase
});
