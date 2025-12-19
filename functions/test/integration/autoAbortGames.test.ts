import * as admin from 'firebase-admin';
import firebaseFunctionsTest from 'firebase-functions-test';
import * as functions from '../../src/index'; // Import functions from index.ts

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

/**
 * Integration tests for autoAbortGames scheduled function.
 *
 * This function runs every 15 minutes to check for scheduled games that have passed
 * their scheduled time and have insufficient players.
 *
 * When a game is auto-aborted:
 * 1. autoAbortGames updates the game status to 'cancelled'
 * 2. The onGameCancelled Firestore trigger (from notifications.ts) automatically fires
 * 3. All players and waitlist users receive notifications (respecting preferences)
 *
 * Note: Notification integration is tested separately in autoAbortGamesNotifications.test.ts
 */
describe('autoAbortGames', () => {
    // Clean up resources after tests
    afterAll(async () => {
        wrappedFunctions.cleanup();
    });

    // Clear Firestore data before each test
    beforeEach(async () => {
        // Use the Firebase Emulator Hub to clear Firestore data
        // This assumes the emulator is running on localhost:8080
        await firestore.recursiveDelete(firestore.collection('games'));
        await firestore.recursiveDelete(firestore.collection('users'));
    });

    test('should abort games with insufficient players after scheduled time', async () => {
        // Arrange
        const gameId1 = 'game1_insufficient_players';
        const gameId2 = 'game2_sufficient_players';
        const gameId3 = 'game3_future_scheduled';
        const gameId4 = 'game4_already_cancelled';
        const gameId5 = 'game5_just_scheduled_past'; // Game scheduled exactly at the "now" for test

        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (30 * 60 * 1000)); // 30 minutes ago
        const nowTime = admin.firestore.Timestamp.fromMillis(Date.now());
        const futureScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() + (30 * 60 * 1000)); // 30 minutes from now

        // Game 1: Insufficient players, scheduled in the past -> SHOULD BE ABORTED
        await firestore.collection('games').doc(gameId1).set({
            title: 'Game 1',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: nowTime,
            scheduledAt: pastScheduledTime,
            location: { name: 'Loc 1' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4, // Min players is 4
            playerIds: ['playerA', 'playerB', 'playerC'], // Only 3 players
            updatedAt: nowTime,
        });

        // Game 2: Sufficient players, scheduled in the past -> SHOULD NOT BE ABORTED
        await firestore.collection('games').doc(gameId2).set({
            title: 'Game 2',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: nowTime,
            scheduledAt: pastScheduledTime,
            location: { name: 'Loc 2' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: ['playerA', 'playerB', 'playerC', 'playerD'], // 4 players
            updatedAt: nowTime,
        });

        // Game 3: Scheduled in the future -> SHOULD NOT BE ABORTED
        await firestore.collection('games').doc(gameId3).set({
            title: 'Game 3',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: nowTime,
            scheduledAt: futureScheduledTime,
            location: { name: 'Loc 3' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: ['playerA', 'playerB'],
            updatedAt: nowTime,
        });

        // Game 4: Already cancelled -> SHOULD NOT BE ABORTED (status check)
        await firestore.collection('games').doc(gameId4).set({
            title: 'Game 4',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: nowTime,
            scheduledAt: pastScheduledTime,
            location: { name: 'Loc 4' },
            status: 'cancelled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: ['playerA', 'playerB'],
            updatedAt: nowTime,
        });

        // Game 5: Insufficient players, scheduled at 'now', within the 15 min window -> SHOULD BE ABORTED
        await firestore.collection('games').doc(gameId5).set({
            title: 'Game 5',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: nowTime,
            scheduledAt: admin.firestore.Timestamp.fromMillis(Date.now() - (10 * 60 * 1000)), // 10 minutes ago
            location: { name: 'Loc 5' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: ['playerA'], // Only 1 player
            updatedAt: nowTime,
        });

        // Act
        // Call the scheduled function directly
        await wrappedFunctions.wrap(functions.autoAbortGames)({});

        // Assert
        const game1Doc = await firestore.collection('games').doc(gameId1).get();
        expect(game1Doc.exists).toBeTruthy();
        expect(game1Doc.data()!.status).toBe('cancelled');
        expect(game1Doc.data()!.notes).toBe('Game auto-aborted due to insufficient players.');

        const game2Doc = await firestore.collection('games').doc(gameId2).get();
        expect(game2Doc.exists).toBeTruthy();
        expect(game2Doc.data()!.status).toBe('scheduled'); // Should remain scheduled

        const game3Doc = await firestore.collection('games').doc(gameId3).get();
        expect(game3Doc.exists).toBeTruthy();
        expect(game3Doc.data()!.status).toBe('scheduled'); // Should remain scheduled

        const game4Doc = await firestore.collection('games').doc(gameId4).get();
        expect(game4Doc.exists).toBeTruthy();
        expect(game4Doc.data()!.status).toBe('cancelled'); // Should remain cancelled

        const game5Doc = await firestore.collection('games').doc(gameId5).get();
        expect(game5Doc.exists).toBeTruthy();
        expect(game5Doc.data()!.status).toBe('cancelled');
        expect(game5Doc.data()!.notes).toBe('Game auto-aborted due to insufficient players.');
    }, 20000); // Increase timeout for integration tests

    test('should not abort games that are still in the future', async () => {
        // Arrange
        const gameId = 'game_future';
        const futureScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() + (60 * 60 * 1000)); // 1 hour from now

        await firestore.collection('games').doc(gameId).set({
            title: 'Future Game',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: futureScheduledTime,
            location: { name: 'Loc F' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 4,
            playerIds: ['playerA'],
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act
        await wrappedFunctions.wrap(functions.autoAbortGames)({});

        // Assert
        const gameDoc = await firestore.collection('games').doc(gameId).get();
        expect(gameDoc.exists).toBeTruthy();
        expect(gameDoc.data()!.status).toBe('scheduled');
    });

    test('should handle games with minPlayers different from 4', async () => {
        // Arrange
        const gameId1 = 'game_min_2_players';
        const gameId2 = 'game_min_3_players';

        const pastScheduledTime = admin.firestore.Timestamp.fromMillis(Date.now() - (30 * 60 * 1000));

        // Game 1: minPlayers=2, has 1 player -> SHOULD BE ABORTED
        await firestore.collection('games').doc(gameId1).set({
            title: 'Game Min 2',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Loc M2' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 2,
            playerIds: ['playerA'], // Only 1 player
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Game 2: minPlayers=3, has 3 players -> SHOULD NOT BE ABORTED
        await firestore.collection('games').doc(gameId2).set({
            title: 'Game Min 3',
            groupId: 'group1',
            createdBy: 'user1',
            createdAt: admin.firestore.Timestamp.now(),
            scheduledAt: pastScheduledTime,
            location: { name: 'Loc M3' },
            status: 'scheduled',
            maxPlayers: 4,
            minPlayers: 3,
            playerIds: ['playerA', 'playerB', 'playerC'], // 3 players
            updatedAt: admin.firestore.Timestamp.now(),
        });

        // Act
        await wrappedFunctions.wrap(functions.autoAbortGames)({});

        // Assert
        const game1Doc = await firestore.collection('games').doc(gameId1).get();
        expect(game1Doc.exists).toBeTruthy();
        expect(game1Doc.data()!.status).toBe('cancelled');

        const game2Doc = await firestore.collection('games').doc(gameId2).get();
        expect(game2Doc.exists).toBeTruthy();
        expect(game2Doc.data()!.status).toBe('scheduled');
    }, 20000);
});
