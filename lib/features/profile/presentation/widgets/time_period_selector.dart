import 'package:flutter/material.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// A horizontal selector for choosing time periods (Story 302.3).
///
/// Displays 4 preset options as chips:
/// - 30d
/// - 90d
/// - 1y
/// - All Time
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  String _getLocalizedLabel(BuildContext context, TimePeriod period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case TimePeriod.thirtyDays:
        return l10n.period30d;
      case TimePeriod.ninetyDays:
        return l10n.period90d;
      case TimePeriod.oneYear:
        return l10n.period1y;
      case TimePeriod.allTime:
        return l10n.periodAllTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TimePeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = TimePeriod.values[index];
          final isSelected = period == selectedPeriod;

          return _PeriodChip(
            label: _getLocalizedLabel(context, period),
            isSelected: isSelected,
            onTap: () => onPeriodChanged(period),
          );
        },
      ),
    );
  }
}

/// Individual chip for a time period.
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
