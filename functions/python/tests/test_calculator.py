"""
Unit tests for ELO rating calculator.

Tests the Weak-Link ELO calculation algorithm with comprehensive coverage
of all formulas, edge cases, and expected behaviors.
"""

import pytest
from rating.calculator import EloCalculator
from rating.models import PlayerRating


class TestCalculateTeamRating:
    """Tests for the Weak-Link team rating formula: 0.7 × R_min + 0.3 × R_max"""

    def test_equal_ratings(self):
        """Team rating should equal player rating when both players have same rating."""
        ratings = [1600.0, 1600.0]
        result = EloCalculator.calculate_team_rating(ratings)
        assert result == 1600.0

    def test_different_ratings(self):
        """Team rating should weight weaker player (min) more heavily."""
        ratings = [1500.0, 1700.0]
        # Expected: 0.7 × 1500 + 0.3 × 1700 = 1050 + 510 = 1560
        result = EloCalculator.calculate_team_rating(ratings)
        assert result == 1560.0

    def test_large_rating_difference(self):
        """Team rating with large skill gap should still favor weaker player."""
        ratings = [1200.0, 2000.0]
        # Expected: 0.7 × 1200 + 0.3 × 2000 = 840 + 600 = 1440
        result = EloCalculator.calculate_team_rating(ratings)
        assert result == 1440.0

    def test_order_independence(self):
        """Team rating should be same regardless of player order."""
        ratings_a = [1500.0, 1700.0]
        ratings_b = [1700.0, 1500.0]
        assert EloCalculator.calculate_team_rating(ratings_a) == \
               EloCalculator.calculate_team_rating(ratings_b)

    def test_invalid_team_size_too_few(self):
        """Should raise ValueError if fewer than 2 players."""
        with pytest.raises(ValueError, match="Expected exactly 2 ratings"):
            EloCalculator.calculate_team_rating([1600.0])

    def test_invalid_team_size_too_many(self):
        """Should raise ValueError if more than 2 players."""
        with pytest.raises(ValueError, match="Expected exactly 2 ratings"):
            EloCalculator.calculate_team_rating([1600.0, 1600.0, 1600.0])


class TestCalculateExpectedWinProbability:
    """Tests for ELO expected win probability: E = 1 / (1 + 10^((R_opponent - R_team) / 400))"""

    def test_equal_teams(self):
        """Equal teams should have 50% win probability."""
        prob = EloCalculator.calculate_expected_win_probability(1600.0, 1600.0)
        assert prob == pytest.approx(0.5, abs=0.001)

    def test_stronger_team(self):
        """Stronger team should have > 50% win probability."""
        # Team with 100 point advantage
        prob = EloCalculator.calculate_expected_win_probability(1700.0, 1600.0)
        # Expected: 1 / (1 + 10^(-100/400)) = 1 / (1 + 10^-0.25) ≈ 0.64
        assert prob == pytest.approx(0.64, abs=0.01)

    def test_weaker_team(self):
        """Weaker team should have < 50% win probability."""
        # Team with 100 point disadvantage
        prob = EloCalculator.calculate_expected_win_probability(1500.0, 1600.0)
        # Expected: 1 / (1 + 10^(100/400)) = 1 / (1 + 10^0.25) ≈ 0.36
        assert prob == pytest.approx(0.36, abs=0.01)

    def test_400_point_advantage(self):
        """400 point advantage should give ~90.9% win probability."""
        prob = EloCalculator.calculate_expected_win_probability(2000.0, 1600.0)
        # Expected: 1 / (1 + 10^-1) = 1 / 1.1 ≈ 0.909
        assert prob == pytest.approx(0.909, abs=0.01)

    def test_400_point_disadvantage(self):
        """400 point disadvantage should give ~9.1% win probability."""
        prob = EloCalculator.calculate_expected_win_probability(1200.0, 1600.0)
        # Expected: 1 / (1 + 10^1) = 1 / 11 ≈ 0.091
        assert prob == pytest.approx(0.091, abs=0.01)

    def test_probability_symmetry(self):
        """Win probabilities of opposite teams should sum to 1."""
        team_a_prob = EloCalculator.calculate_expected_win_probability(1700.0, 1500.0)
        team_b_prob = EloCalculator.calculate_expected_win_probability(1500.0, 1700.0)
        assert team_a_prob + team_b_prob == pytest.approx(1.0, abs=0.001)


class TestCalculateRatingChange:
    """Tests for rating change: ΔR = K × (S - E) where K=32"""

    def test_expected_win(self):
        """Win when expected (E=0.6, S=1) should give small positive change."""
        # ΔR = 32 × (1.0 - 0.6) = 32 × 0.4 = 12.8
        change = EloCalculator.calculate_rating_change(0.6, True)
        assert change == pytest.approx(12.8, abs=0.01)

    def test_expected_loss(self):
        """Loss when expected (E=0.4, S=0) should give small negative change."""
        # ΔR = 32 × (0.0 - 0.4) = 32 × -0.4 = -12.8
        change = EloCalculator.calculate_rating_change(0.4, False)
        assert change == pytest.approx(-12.8, abs=0.01)

    def test_upset_win(self):
        """Win when not expected (E=0.1, S=1) should give large positive change."""
        # ΔR = 32 × (1.0 - 0.1) = 32 × 0.9 = 28.8
        change = EloCalculator.calculate_rating_change(0.1, True)
        assert change == pytest.approx(28.8, abs=0.01)

    def test_upset_loss(self):
        """Loss when not expected (E=0.9, S=0) should give large negative change."""
        # ΔR = 32 × (0.0 - 0.9) = 32 × -0.9 = -28.8
        change = EloCalculator.calculate_rating_change(0.9, False)
        assert change == pytest.approx(-28.8, abs=0.01)

    def test_50_50_win(self):
        """Win in even matchup (E=0.5, S=1) should give half K-factor."""
        # ΔR = 32 × (1.0 - 0.5) = 32 × 0.5 = 16.0
        change = EloCalculator.calculate_rating_change(0.5, True)
        assert change == pytest.approx(16.0, abs=0.01)

    def test_50_50_loss(self):
        """Loss in even matchup (E=0.5, S=0) should give negative half K-factor."""
        # ΔR = 32 × (0.0 - 0.5) = 32 × -0.5 = -16.0
        change = EloCalculator.calculate_rating_change(0.5, False)
        assert change == pytest.approx(-16.0, abs=0.01)


class TestCalculateTeamRatings:
    """Tests for complete team rating calculation"""

    def test_equal_teams_team_a_wins(self):
        """Equal teams: winners gain 16 points, losers lose 16 points."""
        team_a = [
            PlayerRating("p1", 1600.0),
            PlayerRating("p2", 1600.0)
        ]
        team_b = [
            PlayerRating("p3", 1600.0),
            PlayerRating("p4", 1600.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Both teams rated 1600, so E=0.5 for both
        # ΔR = 32 × (1 - 0.5) = 16 for winners
        assert result_a.rating_change == pytest.approx(16.0, abs=0.01)
        assert result_b.rating_change == pytest.approx(-16.0, abs=0.01)

        # Check new ratings
        assert result_a.new_ratings["p1"] == pytest.approx(1616.0, abs=0.01)
        assert result_a.new_ratings["p2"] == pytest.approx(1616.0, abs=0.01)
        assert result_b.new_ratings["p3"] == pytest.approx(1584.0, abs=0.01)
        assert result_b.new_ratings["p4"] == pytest.approx(1584.0, abs=0.01)

    def test_unequal_teams_favorite_wins(self):
        """Stronger team wins: small rating gain, larger loss for weaker team."""
        team_a = [
            PlayerRating("p1", 1700.0),
            PlayerRating("p2", 1700.0)
        ]
        team_b = [
            PlayerRating("p3", 1500.0),
            PlayerRating("p4", 1500.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Team A expected to win, so smaller gain
        assert result_a.rating_change > 0
        assert result_a.rating_change < 16.0  # Less than 50/50 matchup

        # Team B expected to lose, so smaller loss (in magnitude)
        assert result_b.rating_change < 0
        assert abs(result_b.rating_change) < 16.0

    def test_unequal_teams_underdog_wins(self):
        """Weaker team wins: large rating gain, large loss for stronger team."""
        team_a = [
            PlayerRating("p1", 1500.0),
            PlayerRating("p2", 1500.0)
        ]
        team_b = [
            PlayerRating("p3", 1700.0),
            PlayerRating("p4", 1700.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Team A (underdog) wins, so large gain
        assert result_a.rating_change > 16.0  # More than 50/50 matchup

        # Team B (favorite) loses, so large loss
        assert result_b.rating_change < -16.0

    def test_weak_link_team_composition(self):
        """Team rating should properly weight weaker player."""
        team_a = [
            PlayerRating("p1", 1400.0),  # Weak player
            PlayerRating("p2", 1800.0)   # Strong player
        ]
        team_b = [
            PlayerRating("p3", 1600.0),
            PlayerRating("p4", 1600.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Team A rating should be: 0.7 × 1400 + 0.3 × 1800 = 980 + 540 = 1520
        assert result_a.team_rating == pytest.approx(1520.0, abs=0.01)
        # Team B rating: 0.7 × 1600 + 0.3 × 1600 = 1600
        assert result_b.team_rating == pytest.approx(1600.0, abs=0.01)

    def test_both_players_same_rating_change(self):
        """Both players on same team should get identical rating change."""
        team_a = [
            PlayerRating("p1", 1500.0),
            PlayerRating("p2", 1700.0)
        ]
        team_b = [
            PlayerRating("p3", 1600.0),
            PlayerRating("p4", 1600.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Both team A players should get same change
        change_p1 = result_a.new_ratings["p1"] - 1500.0
        change_p2 = result_a.new_ratings["p2"] - 1700.0
        assert change_p1 == pytest.approx(change_p2, abs=0.01)

        # Both team B players should get same change
        change_p3 = result_b.new_ratings["p3"] - 1600.0
        change_p4 = result_b.new_ratings["p4"] - 1600.0
        assert change_p3 == pytest.approx(change_p4, abs=0.01)

    def test_new_players_default_rating(self):
        """New players with default 1600 rating should be handled correctly."""
        team_a = [
            PlayerRating("p1", 1600.0, games_played=0),  # New player
            PlayerRating("p2", 1600.0, games_played=0)   # New player
        ]
        team_b = [
            PlayerRating("p3", 1750.0, games_played=50),
            PlayerRating("p4", 1750.0, games_played=50)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # New players (underdogs) win, should get large rating gain
        assert result_a.rating_change > 16.0
        assert result_a.new_ratings["p1"] > 1600.0
        assert result_a.new_ratings["p2"] > 1600.0

    def test_extreme_rating_difference(self):
        """Should handle extreme rating differences (e.g., 1000 vs 2000)."""
        team_a = [
            PlayerRating("p1", 2000.0),
            PlayerRating("p2", 2000.0)
        ]
        team_b = [
            PlayerRating("p3", 1000.0),
            PlayerRating("p4", 1000.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # Strong team wins against very weak team: very small gain
        assert 0 < result_a.rating_change < 1.0
        # Weak team loses to very strong team: very small loss
        assert -1.0 < result_b.rating_change < 0

    def test_invalid_team_a_size(self):
        """Should raise ValueError if team A doesn't have exactly 2 players."""
        team_a = [PlayerRating("p1", 1600.0)]
        team_b = [
            PlayerRating("p2", 1600.0),
            PlayerRating("p3", 1600.0)
        ]

        with pytest.raises(ValueError, match="Team A must have exactly 2 players"):
            EloCalculator.calculate_team_ratings(team_a, team_b, True)

    def test_invalid_team_b_size(self):
        """Should raise ValueError if team B doesn't have exactly 2 players."""
        team_a = [
            PlayerRating("p1", 1600.0),
            PlayerRating("p2", 1600.0)
        ]
        team_b = [
            PlayerRating("p3", 1600.0),
            PlayerRating("p4", 1600.0),
            PlayerRating("p5", 1600.0)
        ]

        with pytest.raises(ValueError, match="Team B must have exactly 2 players"):
            EloCalculator.calculate_team_ratings(team_a, team_b, True)

    def test_rating_conservation(self):
        """Total rating points should be conserved (sum of changes = 0)."""
        team_a = [
            PlayerRating("p1", 1650.0),
            PlayerRating("p2", 1550.0)
        ]
        team_b = [
            PlayerRating("p3", 1700.0),
            PlayerRating("p4", 1500.0)
        ]

        result_a, result_b = EloCalculator.calculate_team_ratings(team_a, team_b, True)

        # 2 players gain, 2 players lose: total change should be ~0
        # (small floating point error acceptable)
        total_change = (2 * result_a.rating_change) + (2 * result_b.rating_change)
        assert total_change == pytest.approx(0.0, abs=0.01)
