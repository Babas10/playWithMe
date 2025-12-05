"""
ELO Rating Calculator for Beach Volleyball using Weak-Link Team Rating.

This module implements the Weak-Link ELO rating system where:
- Team Rating = 0.7 × R_min + 0.3 × R_max
- Expected Win Probability: E = 1 / (1 + 10^((R_opponent - R_team) / 400))
- Rating Change: ΔR = K × (S - E) where S=1 for win, 0 for loss
- K-factor = 32
- Both players on the same team receive identical rating changes
"""

from typing import Dict, List, Tuple
from .models import PlayerRating, GameData, TeamRatingResult


class EloCalculator:
    """
    Calculator for Weak-Link ELO ratings in beach volleyball.

    The Weak-Link algorithm emphasizes the weaker player on each team,
    reflecting the reality that in beach volleyball, the weaker player
    is often the limiting factor for team success.
    """

    # K-factor determines how much ratings change per game
    K_FACTOR = 32

    # Default rating for new players
    DEFAULT_RATING = 1600.0

    @staticmethod
    def calculate_team_rating(ratings: List[float]) -> float:
        """
        Calculate team rating using Weak-Link formula.

        Formula: Team Rating = 0.7 × R_min + 0.3 × R_max

        This formula weights the weaker player (minimum rating) more heavily,
        reflecting that team performance is limited by the weaker player.

        Args:
            ratings: List of exactly 2 player ratings

        Returns:
            Calculated team rating as a float

        Raises:
            ValueError: If ratings list doesn't contain exactly 2 values
        """
        if len(ratings) != 2:
            raise ValueError(f"Expected exactly 2 ratings, got {len(ratings)}")

        r_min = min(ratings)
        r_max = max(ratings)

        return 0.7 * r_min + 0.3 * r_max

    @staticmethod
    def calculate_expected_win_probability(
        team_rating: float,
        opponent_rating: float
    ) -> float:
        """
        Calculate expected win probability using ELO formula.

        Formula: E = 1 / (1 + 10^((R_opponent - R_team) / 400))

        This is the standard ELO probability formula. A rating difference of 400
        points means the stronger team has a 90.9% chance to win.

        Args:
            team_rating: This team's calculated rating
            opponent_rating: Opponent team's calculated rating

        Returns:
            Probability of winning (0.0 to 1.0)
        """
        rating_diff = opponent_rating - team_rating
        return 1.0 / (1.0 + 10.0 ** (rating_diff / 400.0))

    @classmethod
    def calculate_rating_change(
        cls,
        expected_probability: float,
        actual_result: bool
    ) -> float:
        """
        Calculate rating change using ELO formula.

        Formula: ΔR = K × (S - E)
        where:
            K = K-factor (32)
            S = Actual score (1.0 for win, 0.0 for loss)
            E = Expected win probability

        Args:
            expected_probability: Expected probability of winning (0.0 to 1.0)
            actual_result: True if won, False if lost

        Returns:
            Rating change (positive for better than expected, negative for worse)
        """
        actual_score = 1.0 if actual_result else 0.0
        return cls.K_FACTOR * (actual_score - expected_probability)

    @classmethod
    def calculate_team_ratings(
        cls,
        team_a_players: List[PlayerRating],
        team_b_players: List[PlayerRating],
        team_a_won: bool
    ) -> Tuple[TeamRatingResult, TeamRatingResult]:
        """
        Calculate complete rating update for both teams after a game.

        This is the main entry point for ELO calculation. It:
        1. Calculates team ratings using Weak-Link formula
        2. Computes expected win probabilities
        3. Calculates rating changes for both teams
        4. Returns complete results with new ratings

        Args:
            team_a_players: List of exactly 2 PlayerRating objects for team A
            team_b_players: List of exactly 2 PlayerRating objects for team B
            team_a_won: True if team A won, False if team B won

        Returns:
            Tuple of (team_a_result, team_b_result) with complete rating calculations

        Raises:
            ValueError: If either team doesn't have exactly 2 players
        """
        if len(team_a_players) != 2:
            raise ValueError(f"Team A must have exactly 2 players, got {len(team_a_players)}")
        if len(team_b_players) != 2:
            raise ValueError(f"Team B must have exactly 2 players, got {len(team_b_players)}")

        # Extract current ratings
        team_a_ratings = [p.current_rating for p in team_a_players]
        team_b_ratings = [p.current_rating for p in team_b_players]

        # Calculate team ratings using Weak-Link formula
        team_a_rating = cls.calculate_team_rating(team_a_ratings)
        team_b_rating = cls.calculate_team_rating(team_b_ratings)

        # Calculate expected win probabilities
        team_a_expected = cls.calculate_expected_win_probability(team_a_rating, team_b_rating)
        team_b_expected = cls.calculate_expected_win_probability(team_b_rating, team_a_rating)

        # Calculate rating changes
        team_a_change = cls.calculate_rating_change(team_a_expected, team_a_won)
        team_b_change = cls.calculate_rating_change(team_b_expected, not team_a_won)

        # Build results for team A
        team_a_player_ratings = {p.player_id: p.current_rating for p in team_a_players}
        team_a_new_ratings = {
            p.player_id: p.current_rating + team_a_change
            for p in team_a_players
        }

        team_a_result = TeamRatingResult(
            team_rating=team_a_rating,
            player_ratings=team_a_player_ratings,
            expected_win_probability=team_a_expected,
            rating_change=team_a_change,
            new_ratings=team_a_new_ratings
        )

        # Build results for team B
        team_b_player_ratings = {p.player_id: p.current_rating for p in team_b_players}
        team_b_new_ratings = {
            p.player_id: p.current_rating + team_b_change
            for p in team_b_players
        }

        team_b_result = TeamRatingResult(
            team_rating=team_b_rating,
            player_ratings=team_b_player_ratings,
            expected_win_probability=team_b_expected,
            rating_change=team_b_change,
            new_ratings=team_b_new_ratings
        )

        return team_a_result, team_b_result
