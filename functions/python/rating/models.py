"""
Data models for ELO rating calculation.

This module defines the core data structures used in the Weak-Link ELO rating
system for beach volleyball games.
"""

from dataclasses import dataclass
from typing import List


@dataclass
class PlayerRating:
    """
    Represents a player's current ELO rating information.

    Attributes:
        player_id: Unique identifier for the player (Firestore user ID)
        current_rating: Current ELO rating (default 1600 for new players)
        games_played: Number of games that have contributed to ELO calculation
    """
    player_id: str
    current_rating: float
    games_played: int = 0


@dataclass
class GameData:
    """
    Represents the game data required for ELO calculation.

    Attributes:
        game_id: Unique identifier for the game
        team_a_ids: List of player IDs on team A (must be exactly 2)
        team_b_ids: List of player IDs on team B (must be exactly 2)
        team_a_won: Whether team A won the game (True) or team B won (False)
    """
    game_id: str
    team_a_ids: List[str]
    team_b_ids: List[str]
    team_a_won: bool

    def __post_init__(self):
        """Validate team sizes."""
        if len(self.team_a_ids) != 2:
            raise ValueError(f"Team A must have exactly 2 players, got {len(self.team_a_ids)}")
        if len(self.team_b_ids) != 2:
            raise ValueError(f"Team B must have exactly 2 players, got {len(self.team_b_ids)}")


@dataclass
class TeamRatingResult:
    """
    Represents the ELO rating calculation result for one team.

    Attributes:
        team_rating: Calculated team rating using Weak-Link formula
        player_ratings: Dictionary mapping player_id to their current rating
        expected_win_probability: Calculated probability of winning (0.0 to 1.0)
        rating_change: Change in rating (ΔR) for each player on this team
        new_ratings: Dictionary mapping player_id to their new rating after the game
    """
    team_rating: float
    player_ratings: dict[str, float]
    expected_win_probability: float
    rating_change: float
    new_ratings: dict[str, float]
