"""
Main entry point for Python Cloud Functions.

This module initializes Firebase Admin SDK and exports all Cloud Functions
for the PlayWithMe Beach Volleyball application.
"""

import firebase_admin
from firebase_admin import firestore
from firebase_functions import firestore_fn, options

from rating.handler import on_game_result_updated
from shared.logging_config import configure_logging, get_logger

# Configure structured logging
configure_logging()

# Initialize Firebase Admin SDK (uses default credentials in Cloud Functions)
firebase_admin.initialize_app()

# Get logger for this module
logger = get_logger(__name__)


@firestore_fn.on_document_updated(
    document="games/{gameId}",
    memory=options.MemoryOption.MB_256,
    timeout_sec=60,
    region="us-central1",
)
def calculate_elo_ratings(
    event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot]],
) -> None:
    """
    Cloud Function triggered when a game document is updated.

    This function calculates and updates ELO ratings for all players
    in a completed game using the Weak-Link team rating algorithm.

    Trigger: Firestore document update on games/{gameId}

    The function:
    1. Checks if the game is completed and needs ELO calculation
    2. Validates game data (teams, result)
    3. Calculates new ratings for all 4 players atomically
    4. Updates user documents and creates rating history entries
    5. Marks the game as eloCalculated = true

    Idempotency: Skips games where eloCalculated == true

    Args:
        event: The Firestore trigger event containing document changes
    """
    game_id = event.params.get("gameId", "unknown")

    logger.info(
        "Game document updated, checking for ELO calculation",
        game_id=game_id,
    )

    # Extract before and after data
    before_data = event.data.before.to_dict() if event.data.before.exists else None
    after_data = event.data.after.to_dict() if event.data.after.exists else {}

    if not after_data:
        logger.warning("Game document was deleted, skipping", game_id=game_id)
        return

    # Call the handler
    result = on_game_result_updated(
        game_id=game_id,
        before_data=before_data,
        after_data=after_data,
    )

    logger.info(
        "ELO calculation handler completed",
        game_id=game_id,
        result=result,
    )
