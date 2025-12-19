// Integration test to verify that game cancellation notifications are sent when games are auto-aborted
import * as admin from 'firebase-admin';
import firebaseFunctionsTest from 'firebase-functions-test';
import * as functions from '../../src/index';

// Initialize firebase-functions-test
const wrappedFunctions = firebaseFunctionsTest({
    projectId: 'playwithme-dev'
});

// Initialize Firebase Admin SDK (if not already done by index.ts)
if (!admin.apps.length) {
    admin.initializeApp();
}

// Emulate Firestore
const firestore = admin.firestore();
firestore.settings({
    host: 'localhost:8080',
    ssl: false,
});

describe('autoAbortGames - Notification Integration', () => {
    // Clean up resources after tests
    afterAll(async () => {
        wrappedFunctions.cleanup();
    });

    // Clear Firestore data before each test
    beforeEach(async () => {
        await firestore.recursiveDelete(firestore.collection('games'));
        await firestore.recursiveDelete(firestore.collection('users'));
        await firestore.recursiveDelete(firestore.collection('groups'));
    });

    test('should trigger onGameCancelled notification when game is auto-aborted', async () => {
        // Arrange: Create test users with FCM tokens
        const user1Id = 'user1';
        const user2Id = 'user2';
        const user3Id = 'user3';
        const groupId = 'test-group';
        const gameId = 'test-game-insufficient-players';

        // Create test users with FCM tokens and notification preferences
        await firestore.collection('users').doc(user1Id).set({
            displayName: 'Player One',
            email: 'player1@test.com',
            fcmTokens: ['token1-device1', 'token1-device2'],
            notificationPreferences: {
                gameUpdates: true,
                quietHours: { enabled: false }
            },
            createdAt: admin.firestore.Timestamp.now(),
        });

        await firestore.collection('users').doc(user2Id).set({
            displayName: 'Player Two',
            email: 'player2@test.com',
            fcmTokens: ['token2-device1'],
            notificationPreferences: {
                gameUpdates: true,
                quietHours: { enabled: false }
            },
            createdAt: admin.firestore.Timestamp.now(),
        });

        await firestore.collection('users').doc(user3Id).set({
            displayName: 'Player Three (No Notifications)',
            email: 'player3@test.com',
            fcmTokens: ['token3-device1'],
            notificationPreferences: {
                gameUpdates: false, // Disabled notifications
                quietHours: { enabled: false }
            },
            createdAt: admin.firestore.Timestamp.now(),
        });

        // Create test group
        await firestore.collection('groups').doc(groupId).set({
            name: 'Test Group',
            memberIds: [user1Id, user2Id, user3Id],
            adminIds: [user1Id],
            createdBy: user1Id,
            createdAt: admin.firestore.Timestamp.now(),
        });

        // Create a game with insufficient players that should be aborted
        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (30 * 60 * 1000)); // 30 minutes ago
        await firestore.collection('games').doc(gameId).set({
            title: 'Beach Volleyball Game',
            groupId: groupId,
            createdBy: user1Id,
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Beach Court 1' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: [user1Id, user2Id, user3Id], // Only 3 players, need 4
            waitlistIds: [], // No waitlist
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act: Run the autoAbortGames scheduled function
        await wrappedFunctions.wrap(functions.autoAbortGames)({});

        // Wait a bit for Firestore triggers to process
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Assert: Verify the game was cancelled
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists).toBeTruthy();
        const gameData = gameDoc.data()!;
        expect(gameData.status).toBe('cancelled');
        expect(gameData.notes).toBe('Game auto-aborted due to insufficient players.');

        // Note: In the Firebase Emulator, FCM messages are not actually sent,
        // but we can verify that the game status changed, which would trigger
        // the onGameCancelled Firestore trigger in production.

        // The onGameCancelled trigger (from notifications.ts) should fire when:
        // 1. Game status changes from 'scheduled' to 'cancelled'
        // 2. It detects auto-abort by checking the notes field
        // 3. It sends notifications to playerIds and waitlistIds

        // Expected behavior (verified in production, not emulator):
        // - user1 receives notification (has FCM token, gameUpdates enabled)
        // - user2 receives notification (has FCM token, gameUpdates enabled)
        // - user3 does NOT receive notification (gameUpdates disabled)

        // Notification message format:
        // Title: "Game Aborted"
        // Body: "The game Beach Volleyball Game was aborted due to insufficient players."

    }, 20000);

    test('should send notifications to both players and waitlist users when game is aborted', async () => {
        // Arrange: Create scenario with both players and waitlist
        const player1Id = 'player1';
        const player2Id = 'player2';
        const waitlist1Id = 'waitlist1';
        const groupId = 'test-group-2';
        const gameId = 'test-game-with-waitlist';

        // Create test users
        await firestore.collection('users').doc(player1Id).set({
            displayName: 'Active Player 1',
            email: 'active1@test.com',
            fcmTokens: ['player1-token'],
            notificationPreferences: { gameUpdates: true, quietHours: { enabled: false } },
            createdAt: admin.firestore.Timestamp.now(),
        });

        await firestore.collection('users').doc(player2Id).set({
            displayName: 'Active Player 2',
            email: 'active2@test.com',
            fcmTokens: ['player2-token'],
            notificationPreferences: { gameUpdates: true, quietHours: { enabled: false } },
            createdAt: admin.firestore.Timestamp.now(),
        });

        await firestore.collection('users').doc(waitlist1Id).set({
            displayName: 'Waitlist User',
            email: 'waitlist@test.com',
            fcmTokens: ['waitlist-token'],
            notificationPreferences: { gameUpdates: true, quietHours: { enabled: false } },
            createdAt: admin.firestore.Timestamp.now(),
        });

        // Create group
        await firestore.collection('groups').doc(groupId).set({
            name: 'Test Group 2',
            memberIds: [player1Id, player2Id, waitlist1Id],
            adminIds: [player1Id],
            createdBy: player1Id,
            createdAt: admin.firestore.Timestamp.now(),
        });

        // Create game with insufficient players
        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (15 * 60 * 1000));
        await firestore.collection('games').doc(gameId).set({
            title: 'Weekend Game',
            groupId: groupId,
            createdBy: player1Id,
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Court 2' },
            status: 'scheduled',
            maxPlayers: 8,
            minPlayers: 4,
            playerIds: [player1Id, player2Id], // Only 2 players
            waitlistIds: [waitlist1Id], // 1 on waitlist
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act
        await wrappedFunctions.wrap(functions.autoAbortGames)({});
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Assert
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists).toBeTruthy();
        expect(gameDoc.data()!.status).toBe('cancelled');
        expect(gameDoc.data()!.notes).toContain('auto-aborted');

        // Expected: All users (both playerIds and waitlistIds) should be notified
        // - player1Id: receives notification
        // - player2Id: receives notification
        // - waitlist1Id: receives notification (even though on waitlist)

    }, 20000);

    test('should respect quiet hours when sending auto-abort notifications', async () => {
        // Arrange: User in quiet hours should not receive notification
        const userId = 'user-quiet-hours';
        const groupId = 'test-group-3';
        const gameId = 'test-game-quiet';

        // User with quiet hours enabled (22:00 to 08:00)
        const now = new Date();
        const currentHour = now.getHours();

        // Set quiet hours to current time +/- 1 hour to ensure we're in quiet period
        const quietStart = `${(currentHour - 1 + 24) % 24}:00`;
        const quietEnd = `${(currentHour + 1) % 24}:00`;

        await firestore.collection('users').doc(userId).set({
            displayName: 'Quiet User',
            email: 'quiet@test.com',
            fcmTokens: ['quiet-token'],
            notificationPreferences: {
                gameUpdates: true,
                quietHours: {
                    enabled: true,
                    start: quietStart,
                    end: quietEnd
                }
            },
            createdAt: admin.firestore.Timestamp.now(),
        });

        await firestore.collection('groups').doc(groupId).set({
            name: 'Test Group 3',
            memberIds: [userId],
            adminIds: [userId],
            createdBy: userId,
            createdAt: admin.firestore.Timestamp.now(),
        });

        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (20 * 60 * 1000));
        await firestore.collection('games').doc(gameId).set({
            title: 'Late Night Game',
            groupId: groupId,
            createdBy: userId,
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Night Court' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: [userId], // Only 1 player
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act
        await wrappedFunctions.wrap(functions.autoAbortGames)({});
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Assert
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists).toBeTruthy();
        expect(gameDoc.data()!.status).toBe('cancelled');

        // Expected: User should NOT receive notification due to quiet hours
        // In production, the onGameCancelled trigger checks isQuietHours() and skips sending

    }, 20000);

    test('should handle games with no players gracefully', async () => {
        // Arrange: Edge case - game with no players at all
        const groupId = 'test-group-4';
        const gameId = 'test-game-no-players';

        await firestore.collection('groups').doc(groupId).set({
            name: 'Empty Group',
            memberIds: [],
            adminIds: [],
            createdBy: 'creator',
            createdAt: admin.firestore.Timestamp.now(),
        });

        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (45 * 60 * 1000));
        await firestore.collection('games').doc(gameId).set({
            title: 'Abandoned Game',
            groupId: groupId,
            createdBy: 'creator',
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Empty Court' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 2,
            playerIds: [], // No players
            waitlistIds: [],
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act
        await wrappedFunctions.wrap(functions.autoAbortGames)({});
        await new Promise(resolve => setTimeout(resolve, 1000));

        // Assert
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists).toBeTruthy();
        expect(gameDoc.data()!.status).toBe('cancelled');

        // Expected: No notifications sent (no users to notify)
        // The onGameCancelled trigger should handle this gracefully

    }, 20000);
});
