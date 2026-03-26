// Unit tests for the writeAnalyticsEvent and writePerformanceEvent helpers
// Story 24.2: Instrument Cloud Function triggers with analytics events
// Story 25.2: Add writePerformanceEvent for Cloud Function execution timing

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { writeAnalyticsEvent, writePerformanceEvent } from "../../src/helpers/analytics";

// Mock firebase-admin
jest.mock("firebase-admin", () => {
  const actualAdmin = jest.requireActual("firebase-admin");
  return {
    ...actualAdmin,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(),
      })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
        },
      }
    ),
  };
});

// Mock firebase-functions
jest.mock("firebase-functions", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
}));

describe("writeAnalyticsEvent", () => {
  let mockAdd: jest.Mock;
  let mockDb: any;

  beforeEach(() => {
    jest.clearAllMocks();

    mockAdd = jest.fn().mockResolvedValue({});
    mockDb = {
      collection: jest.fn(() => ({ add: mockAdd })),
    };
    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  it("writes the event document with correct shape", async () => {
    await writeAnalyticsEvent("game_created", { groupId: "g1", sport: "volleyball" });

    expect(mockDb.collection).toHaveBeenCalledWith("analytics_events");
    expect(mockAdd).toHaveBeenCalledWith({
      event: "game_created",
      timestamp: "MOCK_TIMESTAMP",
      properties: { groupId: "g1", sport: "volleyball" },
    });
  });

  it("writes with empty properties when none are provided", async () => {
    await writeAnalyticsEvent("friend_connected");

    expect(mockAdd).toHaveBeenCalledWith({
      event: "friend_connected",
      timestamp: "MOCK_TIMESTAMP",
      properties: {},
    });
  });

  it("does not throw when Firestore write fails", async () => {
    mockAdd.mockRejectedValue(new Error("Firestore unavailable"));

    await expect(writeAnalyticsEvent("game_created", {})).resolves.toBeUndefined();
  });

  it("logs an error when Firestore write fails", async () => {
    const firestoreError = new Error("Firestore unavailable");
    mockAdd.mockRejectedValue(firestoreError);

    await writeAnalyticsEvent("game_created", {});

    expect((functions.logger.error as jest.Mock)).toHaveBeenCalledWith(
      "[analytics] Failed to write event",
      expect.objectContaining({ event: "game_created", err: firestoreError })
    );
  });
});

describe("writePerformanceEvent", () => {
  let mockAdd: jest.Mock;
  let mockDb: any;
  let consoleSpy: jest.SpyInstance;

  beforeEach(() => {
    jest.clearAllMocks();

    mockAdd = jest.fn().mockResolvedValue({});
    mockDb = {
      collection: jest.fn(() => ({ add: mockAdd })),
    };
    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
    consoleSpy = jest.spyOn(console, "log").mockImplementation(() => {});
  });

  afterEach(() => {
    consoleSpy.mockRestore();
  });

  it("writes the performance document with correct shape", async () => {
    await writePerformanceEvent({
      functionName: "getGamesForGroup",
      durationMs: 142,
      uid: "user-123",
      status: "success",
    });

    expect(mockDb.collection).toHaveBeenCalledWith("analytics_events");
    expect(mockAdd).toHaveBeenCalledWith({
      eventType: "function_performance",
      functionName: "getGamesForGroup",
      durationMs: 142,
      uid: "user-123",
      status: "success",
      timestamp: "MOCK_TIMESTAMP",
      metadata: {},
    });
  });

  it("uses null for uid when undefined", async () => {
    await writePerformanceEvent({
      functionName: "getFriends",
      durationMs: 55,
      uid: undefined,
      status: "error",
    });

    expect(mockAdd).toHaveBeenCalledWith(
      expect.objectContaining({ uid: null })
    );
  });

  it("includes metadata when provided", async () => {
    await writePerformanceEvent({
      functionName: "getUsersByIds",
      durationMs: 80,
      uid: "user-abc",
      status: "success",
      metadata: { batchSize: 5 },
    });

    expect(mockAdd).toHaveBeenCalledWith(
      expect.objectContaining({ metadata: { batchSize: 5 } })
    );
  });

  it("emits a structured JSON log", async () => {
    await writePerformanceEvent({
      functionName: "calculateUserRanking",
      durationMs: 310,
      uid: "user-xyz",
      status: "success",
    });

    expect(consoleSpy).toHaveBeenCalledWith(
      JSON.stringify({
        type: "performance",
        function: "calculateUserRanking",
        durationMs: 310,
        status: "success",
        uid: "user-xyz",
      })
    );
  });

  it("does not throw when Firestore write fails", async () => {
    mockAdd.mockRejectedValue(new Error("Firestore unavailable"));

    await expect(
      writePerformanceEvent({
        functionName: "getFriends",
        durationMs: 100,
        uid: "u1",
        status: "success",
      })
    ).resolves.toBeUndefined();
  });

  it("logs an error when Firestore write fails", async () => {
    const firestoreError = new Error("Firestore unavailable");
    mockAdd.mockRejectedValue(firestoreError);

    await writePerformanceEvent({
      functionName: "getFriends",
      durationMs: 100,
      uid: "u1",
      status: "success",
    });

    expect((functions.logger.error as jest.Mock)).toHaveBeenCalledWith(
      "[analytics] Failed to write performance event",
      expect.objectContaining({ functionName: "getFriends", err: firestoreError })
    );
  });
});
