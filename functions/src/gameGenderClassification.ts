// Story 26.4: Game gender detection & type classification
// Listens to game document changes and updates gameGenderType based on player genders.
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { classifyGameGenderType } from "./helpers/classifyGameGenderType";

/**
 * Classifies the game gender type when a game is first created.
 * Runs after the notification trigger independently.
 */
export const onGameCreatedClassifyGender = functions
  .region("europe-west6")
  .firestore.document("games/{gameId}")
  .onCreate(async (snapshot, context) => {
    const game = snapshot.data();
    const gameId = context.params.gameId;
    const playerIds: string[] = game.playerIds || [];

    functions.logger.info(
      "[onGameCreatedClassifyGender] Game created, classifying gender type",
      { gameId, playerCount: playerIds.length }
    );

    try {
      const gameGenderType = await classifyGameGenderType(playerIds);

      if (gameGenderType === null) {
        functions.logger.info(
          "[onGameCreatedClassifyGender] No players yet, skipping classification",
          { gameId }
        );
        return null;
      }

      await admin.firestore().collection("games").doc(gameId).update({
        gameGenderType,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(
        "[onGameCreatedClassifyGender] Game gender type set",
        { gameId, gameGenderType }
      );
    } catch (error) {
      functions.logger.error(
        "[onGameCreatedClassifyGender] Error classifying game gender type",
        { gameId, error }
      );
    }

    return null;
  });

/**
 * Reclassifies the game gender type whenever the player list changes.
 * Fires on any game document update, but only writes when playerIds or
 * guestPlayerIds changed (Story 28.8: guest players included in classification).
 */
export const onGamePlayersChangedClassifyGender = functions
  .region("europe-west6")
  .firestore.document("games/{gameId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const gameId = context.params.gameId;

    const beforePlayers: string[] = before.playerIds || [];
    const afterPlayers: string[] = after.playerIds || [];
    const beforeGuests: string[] = before.guestPlayerIds || [];
    const afterGuests: string[] = after.guestPlayerIds || [];

    // Reclassify when playerIds or guestPlayerIds changed
    const listChanged = (a: string[], b: string[]) =>
      a.length !== b.length ||
      b.some((id: string) => !a.includes(id)) ||
      a.some((id: string) => !b.includes(id));

    if (!listChanged(beforePlayers, afterPlayers) && !listChanged(beforeGuests, afterGuests)) {
      return null;
    }

    const allPlayerIds = [...afterPlayers, ...afterGuests];

    functions.logger.info(
      "[onGamePlayersChangedClassifyGender] Player list changed, reclassifying",
      {
        gameId,
        regularPlayers: afterPlayers.length,
        guestPlayers: afterGuests.length,
        total: allPlayerIds.length,
      }
    );

    try {
      const gameGenderType = await classifyGameGenderType(allPlayerIds);

      if (gameGenderType === null) {
        // All players left — remove the field
        await admin.firestore().collection("games").doc(gameId).update({
          gameGenderType: admin.firestore.FieldValue.delete(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        await admin.firestore().collection("games").doc(gameId).update({
          gameGenderType,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      functions.logger.info(
        "[onGamePlayersChangedClassifyGender] Game gender type reclassified",
        { gameId, gameGenderType }
      );
    } catch (error) {
      functions.logger.error(
        "[onGamePlayersChangedClassifyGender] Error reclassifying game gender type",
        { gameId, error }
      );
    }

    return null;
  });
