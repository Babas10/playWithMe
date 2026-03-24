// Unit tests for healthCheck Cloud Function — Story 22.7 post-deploy smoke test

import {healthCheckHandler} from "../../src/healthCheck";

jest.mock("firebase-functions", () => ({
  https: {
    onCall: jest.fn((handler) => handler),
  },
  logger: {
    info: jest.fn(),
  },
}));

describe("healthCheck Cloud Function", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it("returns status ok", async () => {
    const result = await healthCheckHandler(
      {},
      {} as any
    );
    expect(result.status).toBe("ok");
  });

  it("returns a numeric timestamp", async () => {
    const before = Date.now();
    const result = await healthCheckHandler({}, {} as any);
    const after = Date.now();

    expect(typeof result.timestamp).toBe("number");
    expect(result.timestamp).toBeGreaterThanOrEqual(before);
    expect(result.timestamp).toBeLessThanOrEqual(after);
  });

  it("returns a fresh timestamp on each call", async () => {
    const first = await healthCheckHandler({}, {} as any);
    const second = await healthCheckHandler({}, {} as any);

    expect(second.timestamp).toBeGreaterThanOrEqual(first.timestamp);
  });
});
