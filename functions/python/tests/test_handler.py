# Tests for the Firestore trigger handler and transaction logic.

"""
Unit tests for the ELO rating handler.

These tests verify the handler logic without requiring a live Firestore
connection. Integration tests with the Firebase Emulator should be
written separately.
"""

import pytest
from datetime import datetime
from typing import Any, Dict, List, Optional
from unittest.mock import MagicMock, patch, PropertyMock

from rating.handler import (
    parse_game_data,
    on_game_result_updated,
    RatingHistoryEntry,
    get_opponent_team_string,
    calculate_new_streak,
    get_teammate_ids,
    DEFAULT_RATING,
)


class TestParseGameData:
    """Tests for the parse_game_data function."""

    def test_parse_valid_game_data(self):
        """Test parsing valid game data returns correct tuple."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1", "player2"],
                "teamBPlayerIds": ["player3", "player4"],
            },
            "result": {
                "overallWinner": "teamA",
                "games": [],
            },
        }

        result = parse_game_data("game123", game_data)

        assert result is not None
        team_a_ids, team_b_ids, team_a_won = result
        assert team_a_ids == ["player1", "player2"]
        assert team_b_ids == ["player3", "player4"]
        assert team_a_won is True

    def test_parse_game_data_team_b_won(self):
        """Test parsing when team B is the winner."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1", "player2"],
                "teamBPlayerIds": ["player3", "player4"],
            },
            "result": {
                "overallWinner": "teamB",
                "games": [],
            },
        }

        result = parse_game_data("game123", game_data)

        assert result is not None
        _, _, team_a_won = result
        assert team_a_won is False

    def test_parse_game_data_no_result(self):
        """Test that games without result are skipped."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1", "player2"],
                "teamBPlayerIds": ["player3", "player4"],
            },
        }

        result = parse_game_data("game123", game_data)

        assert result is None

    def test_parse_game_data_no_teams(self):
        """Test that games without teams are skipped."""
        game_data = {
            "result": {
                "overallWinner": "teamA",
                "games": [],
            },
        }

        result = parse_game_data("game123", game_data)

        assert result is None

    def test_parse_game_data_invalid_team_a_size(self):
        """Test that invalid team A size raises ValueError."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1"],  # Only 1 player
                "teamBPlayerIds": ["player3", "player4"],
            },
            "result": {
                "overallWinner": "teamA",
                "games": [],
            },
        }

        with pytest.raises(ValueError, match="Team A must have exactly 2 players"):
            parse_game_data("game123", game_data)

    def test_parse_game_data_invalid_team_b_size(self):
        """Test that invalid team B size raises ValueError."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1", "player2"],
                "teamBPlayerIds": ["player3", "player4", "player5"],  # 3 players
            },
            "result": {
                "overallWinner": "teamA",
                "games": [],
            },
        }

        with pytest.raises(ValueError, match="Team B must have exactly 2 players"):
            parse_game_data("game123", game_data)

    def test_parse_game_data_invalid_winner(self):
        """Test that invalid overall winner raises ValueError."""
        game_data = {
            "teams": {
                "teamAPlayerIds": ["player1", "player2"],
                "teamBPlayerIds": ["player3", "player4"],
            },
            "result": {
                "overallWinner": "invalidTeam",
                "games": [],
            },
        }

        with pytest.raises(ValueError, match="Invalid overall winner"):
            parse_game_data("game123", game_data)

    def test_parse_game_data_empty_teams(self):
        """Test that empty team arrays raise ValueError."""
        game_data = {
            "teams": {
                "teamAPlayerIds": [],
                "teamBPlayerIds": ["player3", "player4"],
            },
            "result": {
                "overallWinner": "teamA",
                "games": [],
            },
        }

        with pytest.raises(ValueError, match="Team A must have exactly 2 players"):
            parse_game_data("game123", game_data)


class TestRatingHistoryEntry:
    """Tests for the RatingHistoryEntry dataclass."""

    def test_to_dict(self):
        """Test that to_dict produces correct Firestore format."""
        now = datetime(2025, 12, 5, 10, 30, 0)
        entry = RatingHistoryEntry(
            game_id="game123",
            old_rating=1600.0,
            new_rating=1632.5,
            rating_change=32.5,
            opponent_team="Alice & Bob",
            won=True,
            timestamp=now,
        )

        result = entry.to_dict()

        assert result["gameId"] == "game123"
        assert result["oldRating"] == 1600.0
        assert result["newRating"] == 1632.5
        assert result["ratingChange"] == 32.5
        assert result["opponentTeam"] == "Alice & Bob"
        assert result["won"] is True
        assert result["timestamp"] == now

    def test_to_dict_loss_entry(self):
        """Test rating history entry for a loss."""
        now = datetime(2025, 12, 5, 10, 30, 0)
        entry = RatingHistoryEntry(
            game_id="game456",
            old_rating=1700.0,
            new_rating=1668.0,
            rating_change=-32.0,
            opponent_team="Charlie & Dave",
            won=False,
            timestamp=now,
        )

        result = entry.to_dict()

        assert result["won"] is False
        assert result["ratingChange"] == -32.0


class TestGetOpponentTeamString:
    """Tests for the get_opponent_team_string function."""

    def test_formats_two_players(self):
        """Test that two player names are joined with &."""
        display_names = {
            "player1": "Alice",
            "player2": "Bob",
            "player3": "Charlie",
            "player4": "Dave",
        }

        result = get_opponent_team_string(display_names, ["player3", "player4"])

        assert result == "Charlie & Dave"

    def test_handles_missing_names(self):
        """Test that missing names show as Unknown."""
        display_names = {
            "player1": "Alice",
        }

        result = get_opponent_team_string(display_names, ["player1", "unknown_player"])

        assert result == "Alice & Unknown"


class TestOnGameResultUpdated:
    """Tests for the on_game_result_updated function."""

    def test_skips_already_calculated(self):
        """Test that already calculated games are skipped."""
        game_data = {
            "eloCalculated": True,
            "status": "completed",
            "teams": {
                "teamAPlayerIds": ["p1", "p2"],
                "teamBPlayerIds": ["p3", "p4"],
            },
            "result": {"overallWinner": "teamA"},
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),  # Won't be used
        )

        assert result["status"] == "skipped"
        assert result["reason"] == "already_calculated"

    def test_skips_non_completed_games(self):
        """Test that non-completed games are skipped."""
        game_data = {
            "eloCalculated": False,
            "status": "scheduled",
            "teams": {
                "teamAPlayerIds": ["p1", "p2"],
                "teamBPlayerIds": ["p3", "p4"],
            },
            "result": {"overallWinner": "teamA"},
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        assert result["status"] == "skipped"
        assert result["reason"] == "not_completed"

    def test_skips_in_progress_games(self):
        """Test that in-progress games are skipped."""
        game_data = {
            "eloCalculated": False,
            "status": "in_progress",
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        assert result["status"] == "skipped"
        assert result["reason"] == "not_completed"

    def test_skips_incomplete_data(self):
        """Test that games without result/teams are skipped."""
        game_data = {
            "eloCalculated": False,
            "status": "completed",
            # No teams or result
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        assert result["status"] == "skipped"
        assert result["reason"] == "incomplete_data"

    def test_returns_error_on_invalid_data(self):
        """Test that invalid team sizes return error status."""
        game_data = {
            "eloCalculated": False,
            "status": "completed",
            "teams": {
                "teamAPlayerIds": ["p1"],  # Invalid: only 1 player
                "teamBPlayerIds": ["p3", "p4"],
            },
            "result": {"overallWinner": "teamA"},
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        assert result["status"] == "error"
        assert result["reason"] == "invalid_data"
        assert "Team A must have exactly 2 players" in result["message"]


class TestIdempotency:
    """Tests for idempotency behavior."""

    def test_idempotent_on_already_calculated_flag(self):
        """Test that the eloCalculated flag prevents reprocessing."""
        # First call - should process
        game_data_before_calc = {
            "eloCalculated": False,
            "status": "completed",
        }

        result1 = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data_before_calc,
            db=MagicMock(),
        )

        # This should skip due to incomplete data (no teams/result)
        assert result1["status"] == "skipped"

        # Second call with eloCalculated=True
        game_data_after_calc = {
            "eloCalculated": True,
            "status": "completed",
        }

        result2 = on_game_result_updated(
            game_id="game123",
            before_data=game_data_before_calc,
            after_data=game_data_after_calc,
            db=MagicMock(),
        )

        assert result2["status"] == "skipped"
        assert result2["reason"] == "already_calculated"


class TestDefaultRating:
    """Tests for default rating constant."""

    def test_default_rating_is_1600(self):
        """Test that the default rating is 1600."""
        assert DEFAULT_RATING == 1600.0


class TestEdgeCases:
    """Tests for edge cases."""

    def test_handles_empty_after_data(self):
        """Test handling of empty after_data (shouldn't happen in practice)."""
        # This tests the handler's behavior when the document is somehow empty
        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data={},
            db=MagicMock(),
        )

        # Should skip due to not completed status
        assert result["status"] == "skipped"

    def test_handles_missing_status_field(self):
        """Test handling when status field is missing."""
        game_data = {
            "eloCalculated": False,
            # No status field
            "teams": {
                "teamAPlayerIds": ["p1", "p2"],
                "teamBPlayerIds": ["p3", "p4"],
            },
            "result": {"overallWinner": "teamA"},
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        # Should skip because status is None, not "completed"
        assert result["status"] == "skipped"
        assert result["reason"] == "not_completed"

    def test_handles_cancelled_game(self):
        """Test that cancelled games are skipped."""
        game_data = {
            "eloCalculated": False,
            "status": "cancelled",
        }

        result = on_game_result_updated(
            game_id="game123",
            before_data=None,
            after_data=game_data,
            db=MagicMock(),
        )

        assert result["status"] == "skipped"
        assert result["reason"] == "not_completed"


# Story 14.6: Tests for new player stats calculation functions
class TestCalculateNewStreak:
    """Tests for the calculate_new_streak function (Story 14.6)."""

    def test_start_winning_streak_from_zero(self):
        """Test starting a winning streak from zero."""
        result = calculate_new_streak(current_streak=0, won=True)
        assert result == 1

    def test_continue_winning_streak(self):
        """Test continuing an existing winning streak."""
        result = calculate_new_streak(current_streak=3, won=True)
        assert result == 4

    def test_break_losing_streak_with_win(self):
        """Test breaking a losing streak with a win."""
        result = calculate_new_streak(current_streak=-2, won=True)
        assert result == 1

    def test_start_losing_streak_from_zero(self):
        """Test starting a losing streak from zero."""
        result = calculate_new_streak(current_streak=0, won=False)
        assert result == -1

    def test_continue_losing_streak(self):
        """Test continuing an existing losing streak."""
        result = calculate_new_streak(current_streak=-4, won=False)
        assert result == -5

    def test_break_winning_streak_with_loss(self):
        """Test breaking a winning streak with a loss."""
        result = calculate_new_streak(current_streak=5, won=False)
        assert result == -1

    def test_long_winning_streak(self):
        """Test a very long winning streak."""
        result = calculate_new_streak(current_streak=20, won=True)
        assert result == 21

    def test_long_losing_streak(self):
        """Test a very long losing streak."""
        result = calculate_new_streak(current_streak=-15, won=False)
        assert result == -16


class TestGetTeammateIds:
    """Tests for the get_teammate_ids function (Story 14.6)."""

    def test_get_teammate_from_two_player_team(self):
        """Test getting teammate from a 2-player team."""
        team_ids = ["player1", "player2"]
        result = get_teammate_ids(team_ids, "player1")
        assert result == ["player2"]

    def test_get_teammate_returns_other_player(self):
        """Test that the player themselves is excluded."""
        team_ids = ["alice", "bob"]
        result = get_teammate_ids(team_ids, "bob")
        assert result == ["alice"]

    def test_get_teammates_preserves_order(self):
        """Test that teammate order is preserved."""
        team_ids = ["player1", "player2"]
        result = get_teammate_ids(team_ids, "player1")
        assert result == ["player2"]

    def test_get_teammate_with_different_ids(self):
        """Test with actual user ID strings."""
        team_ids = ["uid-123-abc", "uid-456-def"]
        result = get_teammate_ids(team_ids, "uid-123-abc")
        assert result == ["uid-456-def"]


class TestRatingHistoryEntryStory146:
    """Tests for RatingHistoryEntry dataclass (Story 14.6 - validation)."""

    def test_rating_history_entry_to_dict(self):
        """Test converting rating history entry to dict."""
        timestamp = datetime(2024, 12, 8, 10, 30, 0)
        entry = RatingHistoryEntry(
            game_id="game-123",
            old_rating=1600.0,
            new_rating=1625.0,
            rating_change=25.0,
            opponent_team="Alice & Bob",
            won=True,
            timestamp=timestamp,
        )

        result = entry.to_dict()

        assert result["gameId"] == "game-123"
        assert result["oldRating"] == 1600.0
        assert result["newRating"] == 1625.0
        assert result["ratingChange"] == 25.0
        assert result["opponentTeam"] == "Alice & Bob"
        assert result["won"] is True
        assert result["timestamp"] == timestamp

    def test_rating_history_entry_loss(self):
        """Test rating history entry for a loss."""
        timestamp = datetime(2024, 12, 8, 15, 0, 0)
        entry = RatingHistoryEntry(
            game_id="game-456",
            old_rating=1650.0,
            new_rating=1630.0,
            rating_change=-20.0,
            opponent_team="Charlie & Dana",
            won=False,
            timestamp=timestamp,
        )

        result = entry.to_dict()

        assert result["gameId"] == "game-456"
        assert result["oldRating"] == 1650.0
        assert result["newRating"] == 1630.0
        assert result["ratingChange"] == -20.0
        assert result["opponentTeam"] == "Charlie & Dana"
        assert result["won"] is False
