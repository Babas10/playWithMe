// Unit tests for hasSubmittedTrainingFeedback Cloud Function
// Story 18.8 — Verifies branding update (gatherli salt) and all business logic branches

import * as admin from "firebase-admin";
import {hasSubmittedTrainingFeedbackHandler} from "../../src/hasSubmittedTrainingFeedback";

// Mock Firebase Admin
jest.mock("firebase-admin", () => {
  const actualAdmin = jest.requireActual("firebase-admin");
  return {
    ...actualAdmin,
    firestore: Object.assign(
      jest.fn(() => ({})),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
        },
      }
    ),
  };
});

// Mock firebase-functions
jest.mock("firebase-functions", () => {
  const _fn = {
    https: {
    HttpsError: class HttpsError extends Error {
      code: string;
      constructor(code: string, message: string) {
        super(message);
        this.code = code;
        this.name = "HttpsError";
      }
    },
    onCall: jest.fn((handler) => handler),
  },
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
  };
  (_fn as any).region = jest.fn(() => _fn);
  return _fn;
})

describe("hasSubmittedTrainingFeedback Cloud Function", () => {
  let mockDb: any;
  let mockFeedbackSnapshot: any;
  let mockFeedbackCollection: any;

  beforeEach(() => {
    jest.clearAllMocks();

    mockFeedbackSnapshot = {empty: true};

    mockFeedbackCollection = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(mockFeedbackSnapshot),
    };

    mockDb = {
      collection: jest.fn(() => ({
        doc: jest.fn(() => ({
          collection: jest.fn(() => mockFeedbackCollection),
        })),
      })),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);
  });

  // ============================================================================
  // Authentication
  // ============================================================================

  describe("Authentication", () => {
    it("should throw unauthenticated if user is not logged in", async () => {
      await expect(
        hasSubmittedTrainingFeedbackHandler(
          {trainingSessionId: "session123"},
          {auth: null} as any
        )
      ).rejects.toThrow("You must be logged in to check feedback status");
    });
  });

  // ============================================================================
  // Input Validation
  // ============================================================================

  describe("Input Validation", () => {
    it("should throw invalid-argument if trainingSessionId is missing", async () => {
      await expect(
        hasSubmittedTrainingFeedbackHandler(
          {} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training session ID is required");
    });

    it("should throw invalid-argument if trainingSessionId is empty string", async () => {
      await expect(
        hasSubmittedTrainingFeedbackHandler(
          {trainingSessionId: ""} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training session ID is required");
    });
  });

  // ============================================================================
  // Feedback Check Logic
  // ============================================================================

  describe("Feedback Check Logic", () => {
    it("should return hasSubmitted false when no feedback exists", async () => {
      mockFeedbackSnapshot = {empty: true};
      mockFeedbackCollection.get.mockResolvedValue(mockFeedbackSnapshot);

      const result = await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.hasSubmitted).toBe(false);
    });

    it("should return hasSubmitted true when feedback exists", async () => {
      mockFeedbackSnapshot = {empty: false};
      mockFeedbackCollection.get.mockResolvedValue(mockFeedbackSnapshot);

      const result = await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "user123"}} as any
      );

      expect(result.hasSubmitted).toBe(true);
    });

    it("should query feedback collection using participant hash", async () => {
      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "user123"}} as any
      );

      expect(mockFeedbackCollection.where).toHaveBeenCalledWith(
        "participantHash",
        "==",
        expect.stringMatching(/^[0-9a-f]{64}$/)
      );
      expect(mockFeedbackCollection.limit).toHaveBeenCalledWith(1);
    });

    it("should generate consistent hash for same user and session", async () => {
      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "user123"}} as any
      );

      const firstHash = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];

      jest.clearAllMocks();
      mockFeedbackCollection.get.mockResolvedValue({empty: true});

      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "user123"}} as any
      );

      const secondHash = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];
      expect(firstHash).toBe(secondHash);
    });

    it("should generate different hash for different sessions", async () => {
      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session-A"},
        {auth: {uid: "user123"}} as any
      );
      const hashA = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];

      jest.clearAllMocks();
      mockFeedbackCollection.get.mockResolvedValue({empty: true});

      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session-B"},
        {auth: {uid: "user123"}} as any
      );
      const hashB = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];

      expect(hashA).not.toBe(hashB);
    });

    it("should generate different hash for different users", async () => {
      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "userA"}} as any
      );
      const hashA = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];

      jest.clearAllMocks();
      mockFeedbackCollection.get.mockResolvedValue({empty: true});

      await hasSubmittedTrainingFeedbackHandler(
        {trainingSessionId: "session123"},
        {auth: {uid: "userB"}} as any
      );
      const hashB = (mockFeedbackCollection.where.mock.calls[0] as any[])[2];

      expect(hashA).not.toBe(hashB);
    });
  });

  // ============================================================================
  // Error Handling
  // ============================================================================

  describe("Error Handling", () => {
    it("should throw internal error on unexpected Firestore failure", async () => {
      mockFeedbackCollection.get.mockRejectedValue(new Error("Firestore error"));

      await expect(
        hasSubmittedTrainingFeedbackHandler(
          {trainingSessionId: "session123"},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Failed to check feedback status. Please try again.");
    });
  });
});
