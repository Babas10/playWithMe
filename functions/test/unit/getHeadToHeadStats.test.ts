// Unit Test: getHeadToHeadStats Callable Function
// Story 301.8: Head-to-Head Stats Retrieval

// NOTE: This is a simplified unit test focusing on function configuration.
// Full end-to-end behavior is tested in:
// - test/integration/decoupledArchitecture.test.ts
// - Integration tests verify actual data retrieval and security

import functionsTest from "firebase-functions-test";

// Initialize Firebase Functions test environment
const test = functionsTest();

describe("getHeadToHeadStats", () => {
  afterAll(() => {
    test.cleanup();
  });

  it("should be exported from getHeadToHeadStats module", () => {
    const { getHeadToHeadStats } = require("../../src/getHeadToHeadStats");
    expect(getHeadToHeadStats).toBeDefined();
    expect(typeof getHeadToHeadStats).toBe("object");
  });

  it("should be an HTTPS callable function", () => {
    const { getHeadToHeadStats } = require("../../src/getHeadToHeadStats");
    // Verify it's a callable function (has __trigger property)
    expect(getHeadToHeadStats.__trigger).toBeDefined();
    expect(getHeadToHeadStats.__trigger.httpsTrigger).toBeDefined();
  });

  it("should be exported in index.ts", () => {
    const index = require("../../src/index");
    expect(index.getHeadToHeadStats).toBeDefined();
  });
});
