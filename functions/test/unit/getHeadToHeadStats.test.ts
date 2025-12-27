// Unit Test: getHeadToHeadStats Callable Function
// Story 301.8: Head-to-Head Stats Retrieval

// NOTE: This is a simplified unit test focusing on module exports.
// Full end-to-end behavior is tested in:
// - test/integration/decoupledArchitecture.test.ts
// - Integration tests verify actual data retrieval and security

describe("getHeadToHeadStats", () => {
  it("should be exported from getHeadToHeadStats module", () => {
    const { getHeadToHeadStats } = require("../../src/getHeadToHeadStats");
    expect(getHeadToHeadStats).toBeDefined();
    expect(typeof getHeadToHeadStats).toBe("function");
  });

  it("should be exported in index.ts", () => {
    const index = require("../../src/index");
    expect(index.getHeadToHeadStats).toBeDefined();
  });
});
