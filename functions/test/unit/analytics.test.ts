// Unit tests for the writeAnalyticsEvent helper
// Story 24.2: Instrument Cloud Function triggers with analytics events

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { writeAnalyticsEvent } from "../../src/helpers/analytics";

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
