// Unit tests for classifyGameGenderType helper (Story 26.4)
// Validates gender classification logic based on player list

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

jest.mock("firebase-functions", () => ({
  logger: {
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
    debug: jest.fn(),
  },
}));

import { classifyGameGenderType } from "../../src/helpers/classifyGameGenderType";

describe("classifyGameGenderType", () => {
  function makeDb(genders: Record<string, string | undefined>) {
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
        return { doc: jest.fn() };
      }),
    };
  }

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("returns null when playerIds is empty", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(makeDb({}));
    const result = await classifyGameGenderType([]);
    expect(result).toBeNull();
  });

  test("returns 'male' when all players are male", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "male", u3: "male" })
    );
    const result = await classifyGameGenderType(["u1", "u2", "u3"]);
    expect(result).toBe("male");
  });

  test("returns 'female' when all players are female", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "female", u2: "female" })
    );
    const result = await classifyGameGenderType(["u1", "u2"]);
    expect(result).toBe("female");
  });

  test("returns 'mix' when players have mixed genders", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: "female", u3: "male" })
    );
    const result = await classifyGameGenderType(["u1", "u2", "u3"]);
    expect(result).toBe("mix");
  });

  test("returns 'mix' when a player has no gender set", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male", u2: undefined })
    );
    const result = await classifyGameGenderType(["u1", "u2"]);
    expect(result).toBe("mix");
  });

  test("returns 'mix' when a player has gender = 'prefer_not_to_say'", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "female", u2: "prefer_not_to_say" })
    );
    const result = await classifyGameGenderType(["u1", "u2"]);
    expect(result).toBe("mix");
  });

  test("short-circuits after first player with unknown gender", async () => {
    let callCount = 0;
    const db = {
      collection: jest.fn(() => ({
        doc: jest.fn((id: string) => ({
          get: jest.fn().mockImplementation(() => {
            callCount++;
            return Promise.resolve({ data: jest.fn().mockReturnValue({}) });
          }),
        })),
      })),
    };
    (admin.firestore as unknown as jest.Mock).mockReturnValue(db);

    const result = await classifyGameGenderType(["u1", "u2", "u3"]);
    expect(result).toBe("mix");
    expect(callCount).toBe(1);
  });

  test("returns 'male' for a single male player", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "male" })
    );
    const result = await classifyGameGenderType(["u1"]);
    expect(result).toBe("male");
  });

  test("returns 'female' for a single female player", async () => {
    (admin.firestore as unknown as jest.Mock).mockReturnValue(
      makeDb({ u1: "female" })
    );
    const result = await classifyGameGenderType(["u1"]);
    expect(result).toBe("female");
  });
});
