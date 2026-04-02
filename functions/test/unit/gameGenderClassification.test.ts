// Unit tests for gameGenderClassification Cloud Functions (Story 26.4)
// Validates onCreate and onUpdate triggers that classify game gender type

import * as admin from "firebase-admin";

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
          delete: jest.fn(() => ({ _methodName: "FieldValue.delete" })),
        },
      }
    ),
  };
});

jest.mock("firebase-functions", () => {
  const _fn = {
    firestore: {
      document: jest.fn(() => ({
        onCreate: jest.fn((handler) => handler),
        onUpdate: jest.fn((handler) => handler),
      })),
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
});

import {
  onGameCreatedClassifyGender,
  onGamePlayersChangedClassifyGender,
} from "../../src/gameGenderClassification";

describe("onGameCreatedClassifyGender", () => {
  let mockGameRef: any;

  function makeDb(genders: Record<string, string | undefined>) {
    mockGameRef = { update: jest.fn().mockResolvedValue(undefined) };
    return {
      collection: jest.fn((name: string) => {
        if (name === "users") {
          return {
            doc: jest.fn((id: string) => ({
              get: jest.fn().mockResolvedValue({
                data: jest.fn().mockReturnValue(
                  genders[id] !== undefined ? { gender: genders[id] } : {}
                ),
              }),
            })),
          };
        }
        if (name === "games") {
          return { doc: jest.fn().mockReturnValue(mockGameRef) };
        }
        return { doc: jest.fn() };
      }),
    };
  }

  beforeEach(() => {
    jest.clearAllMocks();
  });

  function makeSnapshot(playerIds: string[]) {
    return { data: jest.fn().mockReturnValue({ playerIds }) };
  }

  function makeContext(gameId = "game-123") {
    return { params: { gameId } };
  }

  test("classifies game as 'male' when all initial players are male", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "male" })
    );
    await (onGameCreatedClassifyGender as any)(
      makeSnapshot(["u1", "u2"]),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ gameGenderType: "male" })
    );
  });

  test("classifies game as 'female' when all initial players are female", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "female", u2: "female" })
    );
    await (onGameCreatedClassifyGender as any)(
      makeSnapshot(["u1", "u2"]),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ gameGenderType: "female" })
    );
  });

  test("classifies game as 'mix' when players have mixed genders", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "female" })
    );
    await (onGameCreatedClassifyGender as any)(
      makeSnapshot(["u1", "u2"]),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ gameGenderType: "mix" })
    );
  });

  test("skips update when no players at game creation", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(makeDb({}));
    const result = await (onGameCreatedClassifyGender as any)(
      makeSnapshot([]),
      makeContext()
    );
    expect(result).toBeNull();
    expect(mockGameRef.update).not.toHaveBeenCalled();
  });

  test("handles Firestore error gracefully without throwing", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue({
      collection: jest.fn(() => {
        throw new Error("Firestore unavailable");
      }),
    });
    await expect(
      (onGameCreatedClassifyGender as any)(makeSnapshot(["u1"]), makeContext())
    ).resolves.toBeNull();
  });
});

describe("onGamePlayersChangedClassifyGender", () => {
  let mockGameRef: any;

  function makeDb(genders: Record<string, string | undefined>) {
    mockGameRef = { update: jest.fn().mockResolvedValue(undefined) };
    return {
      collection: jest.fn((name: string) => {
        if (name === "users") {
          return {
            doc: jest.fn((id: string) => ({
              get: jest.fn().mockResolvedValue({
                data: jest.fn().mockReturnValue(
                  genders[id] !== undefined ? { gender: genders[id] } : {}
                ),
              }),
            })),
          };
        }
        if (name === "games") {
          return { doc: jest.fn().mockReturnValue(mockGameRef) };
        }
        return { doc: jest.fn() };
      }),
    };
  }

  beforeEach(() => {
    jest.clearAllMocks();
  });

  function makeChange(beforePlayers: string[], afterPlayers: string[]) {
    return {
      before: { data: jest.fn().mockReturnValue({ playerIds: beforePlayers }) },
      after: { data: jest.fn().mockReturnValue({ playerIds: afterPlayers }) },
    };
  }

  function makeContext(gameId = "game-123") {
    return { params: { gameId } };
  }

  test("returns null when playerIds did not change", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(makeDb({}));
    const result = await (onGamePlayersChangedClassifyGender as any)(
      makeChange(["u1", "u2"], ["u1", "u2"]),
      makeContext()
    );
    expect(result).toBeNull();
  });

  test("reclassifies as 'mix' when a female player joins an all-male game", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "male", u3: "female" })
    );
    await (onGamePlayersChangedClassifyGender as any)(
      makeChange(["u1", "u2"], ["u1", "u2", "u3"]),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ gameGenderType: "mix" })
    );
  });

  test("reclassifies as 'male' when only male players remain after a player leaves", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "male" })
    );
    await (onGamePlayersChangedClassifyGender as any)(
      makeChange(["u1", "u2", "u3"], ["u1", "u2"]),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({ gameGenderType: "male" })
    );
  });

  test("deletes gameGenderType field when last player leaves", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(makeDb({}));
    // still need mockGameRef set up
    mockGameRef = { update: jest.fn().mockResolvedValue(undefined) };
    (admin.firestore as unknown as jest.Mock).mockReturnValue({
      collection: jest.fn((name: string) => {
        if (name === "games") return { doc: jest.fn().mockReturnValue(mockGameRef) };
        return { doc: jest.fn() };
      }),
    });
    await (onGamePlayersChangedClassifyGender as any)(
      makeChange(["u1"], []),
      makeContext()
    );
    expect(mockGameRef.update).toHaveBeenCalledWith(
      expect.objectContaining({
        gameGenderType: expect.objectContaining({
          _methodName: "FieldValue.delete",
        }),
      })
    );
  });

  test("handles Firestore error gracefully without throwing", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue({
      collection: jest.fn(() => {
        throw new Error("Firestore unavailable");
      }),
    });
    await expect(
      (onGamePlayersChangedClassifyGender as any)(
        makeChange(["u1"], ["u1", "u2"]),
        makeContext()
      )
    ).resolves.toBeNull();
  });
});
