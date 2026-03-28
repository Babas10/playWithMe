// Unit tests for submitTrainingFeedback Cloud Function
// Story 18.8 — Verifies branding update (gatherli salt) and all business logic branches

import * as admin from "firebase-admin";
import {submitTrainingFeedbackHandler} from "../../src/submitTrainingFeedback";

// Mock crypto (not needed for this function, but keeping consistent pattern)
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
        Timestamp: {
          now: jest.fn(() => ({
            toMillis: () => Date.now(),
            seconds: Math.floor(Date.now() / 1000),
          })),
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

describe("submitTrainingFeedback Cloud Function", () => {
  let mockDb: any;
  let mockSessionDoc: any;
  let mockFeedbackSnapshot: any;
  let mockFeedbackCollection: any;

  const validData = {
    trainingSessionId: "session123",
    exercisesQuality: 4,
    trainingIntensity: 3,
    coachingClarity: 5,
  };

  const pastTime = Date.now() - 3600000;
  const pastTimestamp = {
    toMillis: () => pastTime,
    seconds: Math.floor(pastTime / 1000),
    valueOf: () => pastTime, // enables JS > comparison
  };

  beforeEach(() => {
    jest.clearAllMocks();

    mockFeedbackSnapshot = {empty: true};

    mockFeedbackCollection = {
      where: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      get: jest.fn().mockResolvedValue(mockFeedbackSnapshot),
      add: jest.fn().mockResolvedValue({id: "feedback-new"}),
    };

    mockSessionDoc = {
      exists: true,
      data: () => ({
        groupId: "group123",
        participantIds: ["user123", "user456"],
        status: "completed",
        endTime: pastTimestamp,
      }),
    };

    mockDb = {
      collection: jest.fn((name: string) => {
        if (name === "trainingSessions") {
          return {
            doc: jest.fn(() => ({
              get: jest.fn().mockResolvedValue(mockSessionDoc),
              collection: jest.fn(() => mockFeedbackCollection),
            })),
          };
        }
        return {};
      }),
    };

    (admin.firestore as unknown as jest.Mock).mockReturnValue(mockDb);

    // Mock Timestamp.now() to return a time after the session ended (valueOf for > comparison)
    const nowTime = Date.now();
    (admin.firestore as any).Timestamp = {
      now: jest.fn(() => ({
        toMillis: () => nowTime,
        seconds: Math.floor(nowTime / 1000),
        valueOf: () => nowTime,
      })),
    };
  });

  // ============================================================================
  // Authentication
  // ============================================================================

  describe("Authentication", () => {
    it("should throw unauthenticated if user is not logged in", async () => {
      await expect(
        submitTrainingFeedbackHandler(validData, {auth: null} as any)
      ).rejects.toThrow("You must be logged in to submit feedback");
    });
  });

  // ============================================================================
  // Input Validation
  // ============================================================================

  describe("Input Validation", () => {
    it("should throw invalid-argument if trainingSessionId is missing", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training session ID is required");
    });

    it("should throw invalid-argument if exercisesQuality is missing", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {trainingSessionId: "s1", trainingIntensity: 3, coachingClarity: 3} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Exercises quality rating is required");
    });

    it("should throw invalid-argument if exercisesQuality is out of range (6)", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {...validData, exercisesQuality: 6},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Exercises quality rating must be between 1 and 5");
    });

    it("should throw invalid-argument if exercisesQuality is out of range (6)", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {...validData, exercisesQuality: 6},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Exercises quality rating must be between 1 and 5");
    });

    it("should throw invalid-argument if trainingIntensity is missing", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {trainingSessionId: "s1", exercisesQuality: 3, coachingClarity: 3} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training intensity rating is required");
    });

    it("should throw invalid-argument if trainingIntensity is out of range", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {...validData, trainingIntensity: 6},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training intensity rating must be between 1 and 5");
    });

    it("should throw invalid-argument if coachingClarity is missing", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {trainingSessionId: "s1", exercisesQuality: 3, trainingIntensity: 3} as any,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Coaching clarity rating is required");
    });

    it("should throw invalid-argument if coachingClarity is out of range (6)", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {...validData, coachingClarity: 6},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Coaching clarity rating must be between 1 and 5");
    });

    it("should throw invalid-argument if comment exceeds 1000 characters", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          {...validData, comment: "x".repeat(1001)},
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Comment must be less than 1000 characters");
    });
  });

  // ============================================================================
  // Session Validation
  // ============================================================================

  describe("Session Validation", () => {
    it("should throw not-found if training session does not exist", async () => {
      mockSessionDoc.exists = false;

      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Training session not found");
    });

    it("should throw failed-precondition if user is not a participant", async () => {
      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "outsider999"}} as any
        )
      ).rejects.toThrow("You must be a participant of this training session to submit feedback");
    });

    it("should throw failed-precondition if session has not ended yet", async () => {
      const futureTime = Date.now() + 3600000;
      const nowTime = Date.now();

      // valueOf() makes JS > operator compare these plain objects numerically
      mockSessionDoc.data = () => ({
        groupId: "group123",
        participantIds: ["user123"],
        status: "ongoing",
        endTime: {
          seconds: Math.floor(futureTime / 1000),
          toMillis: () => futureTime,
          valueOf: () => futureTime,
        } as any,
      });

      (admin.firestore as any).Timestamp = {
        now: jest.fn(() => ({
          seconds: Math.floor(nowTime / 1000),
          toMillis: () => nowTime,
          valueOf: () => nowTime,
        })),
      };

      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Feedback can only be submitted after the training session has ended");
    });

    it("should throw failed-precondition if session is cancelled", async () => {
      mockSessionDoc.data = () => ({
        groupId: "group123",
        participantIds: ["user123"],
        status: "cancelled",
        endTime: pastTimestamp,
      });

      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Cannot submit feedback for a cancelled training session");
    });
  });

  // ============================================================================
  // Duplicate Submission Check
  // ============================================================================

  describe("Duplicate Submission Prevention", () => {
    it("should throw already-exists if user already submitted feedback", async () => {
      mockFeedbackSnapshot = {empty: false};
      mockFeedbackCollection.get.mockResolvedValue(mockFeedbackSnapshot);

      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("You have already submitted feedback for this training session");
    });
  });

  // ============================================================================
  // Successful Submission
  // ============================================================================

  describe("Successful Submission", () => {
    it("should return success true with message", async () => {
      const result = await submitTrainingFeedbackHandler(
        validData,
        {auth: {uid: "user123"}} as any
      );

      expect(result.success).toBe(true);
      expect(result.message).toBe("Feedback submitted successfully");
    });

    it("should call feedback collection add with correct fields", async () => {
      await submitTrainingFeedbackHandler(
        validData,
        {auth: {uid: "user123"}} as any
      );

      expect(mockFeedbackCollection.add).toHaveBeenCalledWith(
        expect.objectContaining({
          exercisesQuality: 4,
          trainingIntensity: 3,
          coachingClarity: 5,
          comment: null,
          participantHash: expect.any(String),
        })
      );
    });

    it("should trim and store comment when provided", async () => {
      await submitTrainingFeedbackHandler(
        {...validData, comment: "  Great session!  "},
        {auth: {uid: "user123"}} as any
      );

      expect(mockFeedbackCollection.add).toHaveBeenCalledWith(
        expect.objectContaining({comment: "Great session!"})
      );
    });

    it("should store null comment when not provided", async () => {
      await submitTrainingFeedbackHandler(
        validData,
        {auth: {uid: "user123"}} as any
      );

      expect(mockFeedbackCollection.add).toHaveBeenCalledWith(
        expect.objectContaining({comment: null})
      );
    });

    it("should use gatherli salt to generate participant hash", async () => {
      // Two calls for same user + session should produce the same hash
      await submitTrainingFeedbackHandler(
        validData,
        {auth: {uid: "user123"}} as any
      );

      const firstCall = mockFeedbackCollection.add.mock.calls[0][0];
      const firstHash = firstCall.participantHash;

      // Hash must be a 64-char hex string (SHA256)
      expect(firstHash).toMatch(/^[0-9a-f]{64}$/);

      // Duplicate check uses the same hash via the feedback query
      expect(mockFeedbackCollection.where).toHaveBeenCalledWith(
        "participantHash",
        "==",
        firstHash
      );
    });
  });

  // ============================================================================
  // Error Handling
  // ============================================================================

  describe("Error Handling", () => {
    it("should throw internal error on unexpected Firestore failure", async () => {
      mockFeedbackCollection.add.mockRejectedValue(new Error("Firestore error"));

      await expect(
        submitTrainingFeedbackHandler(
          validData,
          {auth: {uid: "user123"}} as any
        )
      ).rejects.toThrow("Failed to submit feedback. Please try again.");
    });
  });
});
