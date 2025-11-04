// Helper to create reusable Firestore mocks for testing

interface MockFirestoreOptions {
  friendships?: {
    exists?: boolean;
    docs?: any[];
    empty?: boolean;
    addResult?: {id: string};
  };
  users?: {
    [userId: string]: {
      exists: boolean;
      data?: any;
    };
  };
  transaction?: {
    get?: jest.Mock;
    update?: jest.Mock;
  };
}

export function createMockFirestore(options: MockFirestoreOptions = {}) {
  const {
    friendships = {empty: true, docs: [], addResult: {id: "mockFriendship"}},
    users = {},
    transaction = {},
  } = options;

  return {
    collection: jest.fn((name: string) => {
      if (name === "friendships") {
        const mockChain = {
          where: jest.fn().mockReturnThis(),
          limit: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({
            empty: friendships.empty ?? true,
            docs: friendships.docs ?? [],
          }),
        };
        return {
          ...mockChain,
          add: jest.fn().mockResolvedValue(friendships.addResult),
          doc: jest.fn(() => ({
            get: jest.fn().mockResolvedValue({
              exists: friendships.exists ?? false,
              data: () => (friendships.docs?.[0]?.data?.() ?? {}),
            } as any),
            delete: jest.fn().mockResolvedValue(undefined as any),
          })),
        };
      }

      if (name === "users") {
        return {
          doc: jest.fn((userId: string) => ({
            get: jest.fn().mockResolvedValue({
              exists: users[userId]?.exists ?? true,
              id: userId,
              data: () =>
                users[userId]?.data ?? {
                  displayName: userId,
                  email: `${userId}@example.com`,
                },
            } as any),
          })),
          where: jest.fn().mockReturnThis(),
          get: jest.fn().mockResolvedValue({
            docs: Object.keys(users).map((id) => ({
              id,
              data: () => users[id].data,
            })),
          } as any),
        };
      }

      return {};
    }),

    runTransaction: jest.fn(async (callback: any) => {
      const txn = {
        get: transaction.get ?? jest.fn().mockResolvedValue({exists: false} as any),
        update: transaction.update ?? jest.fn().mockResolvedValue(undefined as any),
      };
      await callback(txn);
      return undefined;
    }),

    FieldValue: {
      serverTimestamp: jest.fn(() => new Date()),
    },

    FieldPath: {
      documentId: jest.fn(() => "__name__"),
    },
  };
}
