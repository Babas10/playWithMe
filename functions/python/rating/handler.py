"""
Firestore trigger handler for ELO rating calculations.

This module implements the Cloud Function that automatically calculates
and updates player ELO ratings when a game result is submitted.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple

from firebase_admin import firestore
from google.cloud.firestore import DocumentReference, Transaction

from .calculator import EloCalculator
from .models import PlayerRating
from shared.logging_config import get_logger

logger = get_logger(__name__)

# Default ELO rating for new players
DEFAULT_RATING = 1600.0


@dataclass
class RatingHistoryEntry:
    """Represents a rating history entry to be written to Firestore."""

    game_id: str
    old_rating: float
    new_rating: float
    rating_change: float
    opponent_team: str
    won: bool
    timestamp: datetime

    def to_dict(self) -> Dict[str, Any]:
        """Convert to Firestore-compatible dictionary."""
        return {
            "gameId": self.game_id,
            "oldRating": self.old_rating,
            "newRating": self.new_rating,
            "ratingChange": self.rating_change,
            "opponentTeam": self.opponent_team,
            "won": self.won,
            "timestamp": self.timestamp,
        }


def parse_game_data(
    game_id: str, data: Dict[str, Any]
) -> Optional[Tuple[List[str], List[str], bool]]:
    """
    Parse and validate game data for ELO calculation.

    Args:
        game_id: The game document ID
        data: The game document data

    Returns:
        Tuple of (team_a_ids, team_b_ids, team_a_won) or None if invalid

    Raises:
        ValueError: If game data is invalid or missing required fields
    """
    # Check if game result exists
    result = data.get("result")
    if not result:
        logger.info("Game has no result data", game_id=game_id)
        return None

    # Check if teams are defined
    teams = data.get("teams")
    if not teams:
        logger.info("Game has no teams data", game_id=game_id)
        return None

    team_a_ids = teams.get("teamAPlayerIds", [])
    team_b_ids = teams.get("teamBPlayerIds", [])

    # Validate team sizes (beach volleyball = 2v2)
    if len(team_a_ids) != 2:
        raise ValueError(f"Team A must have exactly 2 players, got {len(team_a_ids)}")
    if len(team_b_ids) != 2:
        raise ValueError(f"Team B must have exactly 2 players, got {len(team_b_ids)}")

    # Determine winner
    overall_winner = result.get("overallWinner")
    if overall_winner not in ("teamA", "teamB"):
        raise ValueError(f"Invalid overall winner: {overall_winner}")

    team_a_won = overall_winner == "teamA"

    return team_a_ids, team_b_ids, team_a_won


def get_player_display_names(
    transaction: Transaction,
    db: firestore.firestore.Client,
    player_ids: List[str],
) -> Dict[str, str]:
    """
    Fetch display names for players from Firestore.

    Args:
        transaction: The Firestore transaction
        db: Firestore client
        player_ids: List of player IDs

    Returns:
        Dictionary mapping player_id to display name
    """
    display_names = {}
    for player_id in player_ids:
        user_ref = db.collection("users").document(player_id)
        user_doc = transaction.get(user_ref)
        if user_doc.exists:
            data = user_doc.to_dict()
            display_names[player_id] = data.get("displayName") or data.get("email", "Unknown")
        else:
            display_names[player_id] = "Unknown"
    return display_names


def get_opponent_team_string(
    display_names: Dict[str, str], opponent_ids: List[str]
) -> str:
    """Get a formatted string representing the opponent team."""
    names = [display_names.get(pid, "Unknown") for pid in opponent_ids]
    return " & ".join(names)


def update_ratings_transaction(
    transaction: Transaction,
    db: firestore.firestore.Client,
    game_ref: DocumentReference,
    game_id: str,
    team_a_ids: List[str],
    team_b_ids: List[str],
    team_a_won: bool,
) -> bool:
    """
    Execute the atomic rating update transaction.

    This function:
    1. Re-checks the eloCalculated flag (race condition prevention)
    2. Fetches current ratings for all 4 players
    3. Calculates new ratings using EloCalculator
    4. Updates user documents atomically
    5. Creates ratingHistory entries for each player
    6. Marks game as eloCalculated = true

    Args:
        transaction: The Firestore transaction
        db: Firestore client
        game_ref: Reference to the game document
        game_id: The game document ID
        team_a_ids: List of player IDs on team A
        team_b_ids: List of player IDs on team B
        team_a_won: Whether team A won

    Returns:
        True if ratings were updated, False if skipped

    Raises:
        Exception: If the transaction fails
    """
    # Re-read game document inside transaction to check eloCalculated
    game_doc = transaction.get(game_ref)
    if not game_doc.exists:
        logger.warning("Game document no longer exists", game_id=game_id)
        return False

    game_data = game_doc.to_dict()
    if game_data.get("eloCalculated", False):
        logger.info(
            "Game already processed (race condition avoided)",
            game_id=game_id,
        )
        return False

    # Gather all player IDs
    all_player_ids = team_a_ids + team_b_ids

    # Fetch current ratings for all players
    player_ratings: Dict[str, PlayerRating] = {}
    user_refs: Dict[str, DocumentReference] = {}

    for player_id in all_player_ids:
        user_ref = db.collection("users").document(player_id)
        user_refs[player_id] = user_ref
        user_doc = transaction.get(user_ref)

        if user_doc.exists:
            data = user_doc.to_dict()
            current_rating = data.get("eloRating", DEFAULT_RATING)
            games_played = data.get("eloGamesPlayed", 0)
        else:
            # New player - use default rating
            current_rating = DEFAULT_RATING
            games_played = 0
            logger.info(
                "New player detected, using default rating",
                player_id=player_id,
                default_rating=DEFAULT_RATING,
            )

        player_ratings[player_id] = PlayerRating(
            player_id=player_id,
            current_rating=current_rating,
            games_played=games_played,
        )

    # Build PlayerRating lists for calculation
    team_a_players = [player_ratings[pid] for pid in team_a_ids]
    team_b_players = [player_ratings[pid] for pid in team_b_ids]

    # Calculate new ratings
    team_a_result, team_b_result = EloCalculator.calculate_team_ratings(
        team_a_players=team_a_players,
        team_b_players=team_b_players,
        team_a_won=team_a_won,
    )

    logger.info(
        "Calculated ratings",
        game_id=game_id,
        team_a_rating=team_a_result.team_rating,
        team_b_rating=team_b_result.team_rating,
        team_a_change=team_a_result.rating_change,
        team_b_change=team_b_result.rating_change,
    )

    # Get display names for rating history entries
    display_names = get_player_display_names(transaction, db, all_player_ids)

    # Current timestamp for all updates
    now = datetime.utcnow()

    # Update Team A players
    for player_id in team_a_ids:
        old_rating = player_ratings[player_id].current_rating
        new_rating = team_a_result.new_ratings[player_id]
        user_ref = user_refs[player_id]

        # Determine new peak rating
        user_doc = transaction.get(user_ref)
        current_peak = old_rating
        current_peak_date = None
        if user_doc.exists:
            data = user_doc.to_dict()
            current_peak = data.get("eloPeak", old_rating)
            current_peak_date = data.get("eloPeakDate")

        new_peak = max(current_peak, new_rating)
        peak_date = now if new_rating > current_peak else current_peak_date

        # Update user document
        update_data = {
            "eloRating": new_rating,
            "eloLastUpdated": now,
            "eloPeak": new_peak,
            "eloGamesPlayed": firestore.firestore.Increment(1),
        }
        if peak_date:
            update_data["eloPeakDate"] = peak_date

        transaction.update(user_ref, update_data)

        # Create rating history entry
        history_entry = RatingHistoryEntry(
            game_id=game_id,
            old_rating=old_rating,
            new_rating=new_rating,
            rating_change=team_a_result.rating_change,
            opponent_team=get_opponent_team_string(display_names, team_b_ids),
            won=team_a_won,
            timestamp=now,
        )
        history_ref = user_ref.collection("ratingHistory").document()
        transaction.set(history_ref, history_entry.to_dict())

        logger.info(
            "Updated player rating",
            player_id=player_id,
            old_rating=old_rating,
            new_rating=new_rating,
            change=team_a_result.rating_change,
            team="A",
            won=team_a_won,
        )

    # Update Team B players
    for player_id in team_b_ids:
        old_rating = player_ratings[player_id].current_rating
        new_rating = team_b_result.new_ratings[player_id]
        user_ref = user_refs[player_id]

        # Determine new peak rating
        user_doc = transaction.get(user_ref)
        current_peak = old_rating
        current_peak_date = None
        if user_doc.exists:
            data = user_doc.to_dict()
            current_peak = data.get("eloPeak", old_rating)
            current_peak_date = data.get("eloPeakDate")

        new_peak = max(current_peak, new_rating)
        peak_date = now if new_rating > current_peak else current_peak_date

        # Update user document
        update_data = {
            "eloRating": new_rating,
            "eloLastUpdated": now,
            "eloPeak": new_peak,
            "eloGamesPlayed": firestore.firestore.Increment(1),
        }
        if peak_date:
            update_data["eloPeakDate"] = peak_date

        transaction.update(user_ref, update_data)

        # Create rating history entry
        history_entry = RatingHistoryEntry(
            game_id=game_id,
            old_rating=old_rating,
            new_rating=new_rating,
            rating_change=team_b_result.rating_change,
            opponent_team=get_opponent_team_string(display_names, team_a_ids),
            won=not team_a_won,
            timestamp=now,
        )
        history_ref = user_ref.collection("ratingHistory").document()
        transaction.set(history_ref, history_entry.to_dict())

        logger.info(
            "Updated player rating",
            player_id=player_id,
            old_rating=old_rating,
            new_rating=new_rating,
            change=team_b_result.rating_change,
            team="B",
            won=not team_a_won,
        )

    # Mark game as eloCalculated
    transaction.update(
        game_ref,
        {
            "eloCalculated": True,
            "eloCalculatedAt": now,
        },
    )

    return True


def on_game_result_updated(
    game_id: str,
    before_data: Optional[Dict[str, Any]],
    after_data: Dict[str, Any],
    db: Optional[firestore.firestore.Client] = None,
) -> Dict[str, Any]:
    """
    Handle game document updates and trigger ELO calculation.

    This is the main entry point called by the Cloud Function trigger.
    It implements idempotency by checking the eloCalculated flag.

    Args:
        game_id: The game document ID
        before_data: The document data before the update (None for new docs)
        after_data: The document data after the update
        db: Optional Firestore client (for testing)

    Returns:
        Dictionary with status and message
    """
    logger.set_context(game_id=game_id)

    try:
        # Get Firestore client if not provided
        if db is None:
            db = firestore.client()

        # Check if already calculated (idempotency)
        if after_data.get("eloCalculated", False):
            logger.info("Game already has ELO calculated, skipping")
            return {"status": "skipped", "reason": "already_calculated"}

        # Check if game status is completed
        status = after_data.get("status")
        if status != "completed":
            logger.info("Game not completed, skipping", status=status)
            return {"status": "skipped", "reason": "not_completed"}

        # Parse game data
        parsed = parse_game_data(game_id, after_data)
        if parsed is None:
            logger.info("Game data incomplete, skipping")
            return {"status": "skipped", "reason": "incomplete_data"}

        team_a_ids, team_b_ids, team_a_won = parsed

        logger.set_context(
            game_id=game_id,
            team_a=team_a_ids,
            team_b=team_b_ids,
            team_a_won=team_a_won,
        )

        logger.info("Starting ELO calculation")

        # Get reference to game document
        game_ref = db.collection("games").document(game_id)

        # Execute transaction
        @firestore.firestore.transactional
        def _transaction_wrapper(transaction: Transaction) -> bool:
            return update_ratings_transaction(
                transaction=transaction,
                db=db,
                game_ref=game_ref,
                game_id=game_id,
                team_a_ids=team_a_ids,
                team_b_ids=team_b_ids,
                team_a_won=team_a_won,
            )

        transaction = db.transaction()
        success = _transaction_wrapper(transaction)

        if success:
            logger.info("ELO calculation completed successfully")
            return {"status": "success", "message": "Ratings updated"}
        else:
            logger.info("ELO calculation skipped (likely race condition)")
            return {"status": "skipped", "reason": "transaction_skipped"}

    except ValueError as e:
        logger.error(f"Invalid game data: {e}")
        return {"status": "error", "reason": "invalid_data", "message": str(e)}

    except Exception as e:
        logger.exception(f"Unexpected error during ELO calculation: {e}")
        raise  # Re-raise to trigger Cloud Function retry

    finally:
        logger.clear_context()
