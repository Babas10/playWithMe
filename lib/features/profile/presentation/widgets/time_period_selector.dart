import 'package:flutter/material.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

/// A horizontal selector for choosing time periods (Story 302.3).
///
/// Displays 5 preset options as chips:
/// - 15 Days
/// - 30 Days
/// - 90 Days
/// - 1 Year
/// - All Time
class TimePeriodSelector extends StatelessWidget {
  final TimePeriod selectedPeriod;
  final ValueChanged<TimePeriod> onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

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
            label: period.displayName,
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
