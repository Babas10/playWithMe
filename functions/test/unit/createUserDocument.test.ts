// Unit tests for createUserDocument Auth onCreate trigger.
// Validates correct document creation and the displayName omission fix for
// the race condition against updateUserNames (issue #724).

import * as admin from "firebase-admin";
import { createUserDocument } from "../../src/createUserDocument";

// ── Mock firebase-admin ──────────────────────────────────────────────────────

const mockSet = jest.fn().mockResolvedValue(undefined);
const mockUpdate = jest.fn().mockResolvedValue(undefined);
const mockGet = jest.fn();
const mockDocRef = { set: mockSet, update: mockUpdate };

jest.mock("firebase-admin", () => {
  const actual = jest.requireActual("firebase-admin");
  return {
    ...actual,
    firestore: Object.assign(
      jest.fn(() => ({
        collection: jest.fn(() => ({
          doc: jest.fn(() => mockDocRef),
        })),
      })),
      {
        FieldValue: {
          serverTimestamp: jest.fn(() => "MOCK_TIMESTAMP"),
        },
        Timestamp: {
          fromDate: jest.fn((d: Date) => ({ _seconds: Math.floor(d.getTime() / 1000) })),
        },
      }
    ),
  };
});

// ── Mock firebase-functions ──────────────────────────────────────────────────

jest.mock("firebase-functions", () => {
  const fn: any = {
    auth: {
      user: jest.fn(() => ({ onCreate: jest.fn((h: any) => h), onDelete: jest.fn((h: any) => h) })),
    },
    logger: { info: jest.fn(), warn: jest.fn(), error: jest.fn() },
  };
  fn.region = jest.fn(() => fn);
  return fn;
});

// ── Helpers ──────────────────────────────────────────────────────────────────

function makeUser(overrides: Partial<{
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  emailVerified: boolean;
  providerData: { providerId: string }[];
}> = {}) {
  return {
    uid: "uid-test",
    email: "test@example.com",
    displayName: null,
    photoURL: null,
    emailVerified: false,
    providerData: [{ providerId: "password" }],
    ...overrides,
  } as any;
}

// ── Tests ────────────────────────────────────────────────────────────────────

describe("createUserDocument", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Default: doc does not exist
    mockDocRef.set = mockSet;
    mockDocRef.update = mockUpdate;
    (mockDocRef as any).get = mockGet;
    mockGet.mockResolvedValue({ exists: false, data: () => undefined });
    (admin.firestore as unknown as jest.Mock).mockReturnValue({
      collection: jest.fn(() => ({ doc: jest.fn(() => mockDocRef) })),
    });
  });

  // ── displayName race-condition fix (issue #724) ────────────────────────────

  describe("displayName omission for email/password signups", () => {
    it("does NOT write displayName when Auth has no displayName (email/password)", async () => {
      const user = makeUser({ displayName: null });

      await (createUserDocument as any)(user);

      expect(mockSet).toHaveBeenCalledTimes(1);
      const writtenData = mockSet.mock.calls[0][0];
      expect(writtenData).not.toHaveProperty("displayName");
    });

    it("DOES write displayName when Auth provides one (OAuth provider)", async () => {
      const user = makeUser({
        displayName: "Jane Doe",
        providerData: [{ providerId: "google.com" }],
      });

      await (createUserDocument as any)(user);

      expect(mockSet).toHaveBeenCalledTimes(1);
      const writtenData = mockSet.mock.calls[0][0];
      expect(writtenData.displayName).toBe("Jane Doe");
    });
  });

  // ── Document creation ─────────────────────────────────────────────────────

  describe("new user document", () => {
    it("creates document with correct fields for email/password signup", async () => {
      const user = makeUser({ email: "hello@example.com", emailVerified: false });

      await (createUserDocument as any)(user);

      expect(mockSet).toHaveBeenCalledTimes(1);
      const [data, options] = mockSet.mock.calls[0];
      expect(options).toEqual({ merge: true });
      expect(data.email).toBe("hello@example.com");
      expect(data.eloRating).toBe(1200);
      expect(data.gamesPlayed).toBe(0);
      expect(data.friendIds).toEqual([]);
      expect(data.groupIds).toEqual([]);
      expect(data.accountStatus).toBe("pendingVerification");
    });

    it("sets accountStatus to active for already-verified users (e.g. OAuth)", async () => {
      const user = makeUser({ emailVerified: true, providerData: [{ providerId: "google.com" }] });

      await (createUserDocument as any)(user);

      const writtenData = mockSet.mock.calls[0][0];
      expect(writtenData.accountStatus).toBe("active");
    });

    it("uses merge:true so concurrent updateUserNames fields are preserved", async () => {
      const user = makeUser();

      await (createUserDocument as any)(user);

      expect(mockSet.mock.calls[0][1]).toEqual({ merge: true });
    });
  });

  // ── Existing document handling ────────────────────────────────────────────

  describe("existing document", () => {
    function buildDbWithExistingDoc(existingEmail: string, extraFields: Record<string, unknown> = {}) {
      const docUpdate = jest.fn().mockResolvedValue(undefined);
      const docGet = jest.fn().mockResolvedValue({
        exists: true,
        data: () => ({ email: existingEmail, ...extraFields }),
      });
      const db = {
        collection: jest.fn(() => ({
          doc: jest.fn(() => ({ get: docGet, set: mockSet, update: docUpdate })),
        })),
      };
      return { db, docUpdate };
    }

    it("patches email when doc exists but email is missing", async () => {
      const { db, docUpdate } = buildDbWithExistingDoc("");
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);
      const user = makeUser({ email: "real@example.com" });

      await (createUserDocument as any)(user);

      expect(mockSet).not.toHaveBeenCalled();
      expect(docUpdate).toHaveBeenCalledWith(expect.objectContaining({ email: "real@example.com" }));
    });

    it("skips entirely when doc exists with email and isEmailVerified already set", async () => {
      const { db, docUpdate } = buildDbWithExistingDoc("existing@example.com", { isEmailVerified: true });
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);
      const user = makeUser({ email: "existing@example.com" });

      await (createUserDocument as any)(user);

      expect(mockSet).not.toHaveBeenCalled();
      expect(docUpdate).not.toHaveBeenCalled();
    });

    it("patches isEmailVerified when doc exists with email but missing isEmailVerified", async () => {
      const { db, docUpdate } = buildDbWithExistingDoc("existing@example.com");
      (admin.firestore as unknown as jest.Mock).mockReturnValue(db);
      const user = makeUser({ email: "existing@example.com", emailVerified: true });

      await (createUserDocument as any)(user);

      expect(mockSet).not.toHaveBeenCalled();
      expect(docUpdate).toHaveBeenCalledWith(expect.objectContaining({ isEmailVerified: true }));
    });
  });
});
