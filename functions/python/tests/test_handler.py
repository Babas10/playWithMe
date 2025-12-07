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
