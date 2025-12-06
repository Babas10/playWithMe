"""
ELO Rating calculation module.

This module implements the Weak-Link ELO rating system for beach volleyball.
"""

from .calculator import EloCalculator
from .handler import on_game_result_updated, RatingHistoryEntry
from .models import PlayerRating, GameData, TeamRatingResult

__all__ = [
    'EloCalculator',
    'PlayerRating',
    'GameData',
    'TeamRatingResult',
    'on_game_result_updated',
    'RatingHistoryEntry',
]
