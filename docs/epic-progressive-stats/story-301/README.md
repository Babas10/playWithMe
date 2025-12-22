# Story 301: Statistics Layout with Progressive Disclosure

**Parent Issue:** [#301](https://github.com/Babas10/playWithMe/issues/301)

## Overview

Implemented a three-tier progressive disclosure system for player statistics:
1. **Glance** - Home Screen (< 3 second feedback)
2. **Explore** - Profile/Stats Screen (deeper insights)
3. **Analyze** - Detail Screens (full breakdowns) - *Deferred to Phase 3*

## Completed Phases

### ✅ Phase 1: Home Screen Glance-Level Stats ([#302](https://github.com/Babas10/playWithMe/issues/302))

**Widgets Created:**
- `CompactStatCard` - Streamlined stat display for home
- `ELOTrendIndicator` - Current ELO with trend arrow and delta
- `WinStreakBadge` - Win/loss streak display (only if ≥ 2)
- `HomeStatsSection` - Combines all glance-level components

**Stats Displayed:**
- Current ELO + Trend (↑/↓ with delta over last 5 games)
- Win Rate (percentage + W-L record)
- Games Played
- Win Streak Badge (conditional)

**Integration:**
- Added `PlayerStatsBloc` to HomePage
- Updated `_HomeTab` to use `BlocBuilder<PlayerStatsBloc>`
- Proper loading, error, and loaded states

**Location:** `lib/features/profile/presentation/widgets/`

---

### ✅ Phase 2: Profile/Stats Screen Explore-Level Stats ([#303](https://github.com/Babas10/playWithMe/issues/303))

**Widgets Created:**
- `PerformanceOverviewCard` - Comprehensive performance metrics
- `MonthlyImprovementChart` - Long-term ELO progress tracking
- `MomentumConsistencyCard` - Streak + monthly chart combined
- `PartnersCard` - Best partner statistics
- `RivalsCard` - Nemesis tracking (placeholder for future)
- `RoleBasedPerformanceCard` - Weak-link/carry win rates (collapsible, placeholder)
- `ExpandedStatsSection` - Combines all explore-level cards

**Stats Displayed:**

#### 📊 Performance Overview
- Current ELO
- Peak ELO (with date)
- Games Played
- Win Rate (with W-L record)
- Best Win (placeholder)
- Avg Point Differential (placeholder)

#### 🔥 Momentum & Consistency
- Current win streak (with visual emoji)
- Monthly Improvement Chart:
  - Shows end-of-month ELO snapshots
  - Highlights best and worst months
  - Only appears with ≥ 2 months of data

#### 🤝 Partners
- Best partner (highest win rate, min 5 games)
- Win rate percentage
- Games won/lost together
- Tap navigation (deferred to Phase 3)

#### 🆚 Rivals
- Placeholder for nemesis tracking
- Coming soon state

#### 🧠 Role-Based Performance
- Collapsible advanced section
- Placeholder for weak-link and carry win rates
- Preview of future metrics

**Integration:**
- Updated `ProfilePage` to use `ExpandedStatsSection`
- Proper loading/error states with BlocBuilder
- Removed old `PlayerStatsSection`

**Location:** `lib/features/profile/presentation/widgets/`

---

## Deferred Phases

### ⏳ Phase 3: Detail Screens for Deep Analysis ([#304](https://github.com/Babas10/playWithMe/issues/304))

**Status:** Not Started
**Scope:** Partner detail page, head-to-head page, full ELO history

### ⏳ Phase 4: Empty States and Edge Cases ([#305](https://github.com/Babas10/playWithMe/issues/305))

**Status:** Not Started
**Scope:** Empty state placeholders, loading states, error handling

### ⏳ Phase 5: Testing and Documentation ([#306](https://github.com/Babas10/playWithMe/issues/306))

**Status:** Partially Complete
**Completed:**
- Documentation (this file)
- Code compiles with 0 errors

**Remaining:**
- Unit tests for all widgets
- Widget tests for complex components
- Integration tests for stat calculations
- Coverage validation (target: ≥ 90%)

---

## Architecture

### BLoC Pattern
```
PlayerStatsBloc
├── Events
│   └── LoadPlayerStats(userId)
├── States
│   ├── PlayerStatsInitial
│   ├── PlayerStatsLoading
│   ├── PlayerStatsLoaded(user, history)
│   └── PlayerStatsError(message)
└── Logic
    ├── Listen to UserRepository.getUserStream()
    └── Fetch RatingHistory when needed
```

### Data Flow
```
UserRepository
├── getUserStream(userId) → Stream<UserModel>
└── getRatingHistory(userId) → Stream<List<RatingHistoryEntry>>

↓

PlayerStatsBloc
├── Combines user data + rating history
└── Emits PlayerStatsLoaded state

↓

UI Widgets
├── HomeStatsSection (glance level)
└── ExpandedStatsSection (explore level)
```

### Widget Hierarchy

**Home Screen:**
```
_HomeTab
└── BlocBuilder<PlayerStatsBloc>
    └── HomeStatsSection
        ├── ELOTrendIndicator
        ├── CompactStatCard (Win Rate)
        ├── CompactStatCard (Games Played)
        └── WinStreakBadge (conditional)
```

**Profile Screen:**
```
ProfilePage
└── BlocBuilder<PlayerStatsBloc>
    └── ExpandedStatsSection
        ├── PerformanceOverviewCard
        ├── MomentumConsistencyCard
        │   ├── Streak display
        │   └── MonthlyImprovementChart
        ├── PartnersCard
        ├── RivalsCard
        └── RoleBasedPerformanceCard (collapsible)
```

---

## Key Design Decisions

### 1. Progressive Disclosure Strategy
- **Why:** Avoid overwhelming users with too much information at once
- **How:** Three distinct levels (Glance → Explore → Analyze)
- **Result:** Users get instant feedback on home, deeper insights on profile

### 2. Monthly Chart Over Daily/Weekly
- **Why:** Reduces noise, encourages patience, aligns with improvement cycles
- **Data Point:** End-of-month ELO snapshot
- **Threshold:** Requires ≥ 2 months of data to display

### 3. Best Partner Calculation
- **Criteria:** Highest win rate with minimum 5 games threshold
- **Tiebreaker:** Most games played
- **Source:** `UserModel.teammateStats` map

### 4. Placeholder for Future Features
- **Best Win:** Requires opponent ELO tracking
- **Avg Point Differential:** Requires detailed score tracking
- **Nemesis/Rival:** Requires opponent history tracking
- **Role-Based Stats:** Requires team composition analysis

---

## Files Modified

### Created
```
lib/features/profile/presentation/widgets/
├── compact_stat_card.dart
├── elo_trend_indicator.dart
├── win_streak_badge.dart
├── home_stats_section.dart
├── performance_overview_card.dart
├── monthly_improvement_chart.dart
├── momentum_consistency_card.dart
├── partners_card.dart
├── rivals_card.dart
├── role_based_performance_card.dart
└── expanded_stats_section.dart
```

### Modified
```
lib/app/play_with_me_app.dart
lib/features/profile/presentation/pages/profile_page.dart
```

### Documentation
```
docs/epic-progressive-stats/story-301/README.md
```

---

## Testing Status

**Current:** ⚠️ No tests written yet

**Required Tests (Phase 5):**
- Unit tests for all 11 widgets
- Widget tests for HomeStatsSection, ExpandedStatsSection
- BLoC tests for PlayerStatsBloc (if modified)
- Integration tests for stat calculations

**Coverage Target:** ≥ 90% for all widgets and BLoC logic

---

## Future Enhancements

### Phase 3 - Detail Screens
1. **Partner Detail Page**
   - Full win/loss breakdown with partner
   - ELO change when playing together
   - Recent games together

2. **Head-to-Head Page**
   - Record against specific opponent
   - Point differential
   - Trend over time

3. **Full ELO History Page**
   - Zoomable chart
   - Filter by date range
   - Export functionality

### Phase 4 - Data Tracking
1. **Best Win Tracking**
   - Store opponent team ELO at time of game
   - Calculate and display biggest victory

2. **Point Differential Tracking**
   - Track detailed scores per game
   - Calculate average margin of victory/defeat

3. **Nemesis/Rival Detection**
   - Track opponents faced
   - Identify toughest matchups

4. **Role-Based Analytics**
   - Detect team composition (ELO rankings)
   - Track win rate as weak link
   - Track win rate as carry player

---

## Success Metrics

✅ **Implemented:**
- Users see instant stats feedback on home screen (< 3 seconds)
- Users can explore deeper stats on profile page
- Stats feel motivating, not judgmental
- Layout is clean and organized by theme

⏳ **Pending:**
- Advanced insights are optional (Phase 3)
- Layout scales as new stats are added (Phase 4)
- All stats have proper empty states (Phase 4)
- Comprehensive test coverage (Phase 5)

---

## Compliance with CLAUDE.md

- ✅ BLoC with Repository Pattern
- ✅ Clean separation: UI (widgets) ← BLoC (state) ← Repository (data)
- ✅ DRY principle: Reusable widgets (CompactStatCard, _StatItem, etc.)
- ✅ Error handling: Proper states in BLoC
- ⏳ Testing: Required in Phase 5
- ✅ Code compiles with 0 errors
- ✅ Documentation provided

---

## Deployment Notes

**No Backend Changes Required:**
- All stats use existing UserModel fields
- All data fetched from existing repositories
- Placeholders added for future backend enhancements

**No Breaking Changes:**
- Old `PlayerStatsSection` removed but not referenced elsewhere
- All existing functionality preserved

---

**Last Updated:** 2025-12-21
**Status:** Phases 1-2 Complete, Phases 3-5 Pending
