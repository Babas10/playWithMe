import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_bloc.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_event.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GenderSelectionPage extends StatelessWidget {
  const GenderSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<GenderSelectionBloc, GenderSelectionState>(
      listener: (context, state) {
        if (state is GenderSelectionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.genderSelectionError),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: BlocBuilder<GenderSelectionBloc, GenderSelectionState>(
              builder: (context, state) {
                final selectedGender = state is GenderSelectionRequired
                    ? state.selectedGender
                    : null;
                final isSaving = state is GenderSelectionSaving;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.sports_volleyball,
                      size: 64,
                      color: Color(0xFF6750A4),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.genderSelectionTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.genderSelectionSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    _GenderCard(
                      label: l10n.genderMale,
                      icon: Icons.male,
                      value: UserGender.male,
                      selected: selectedGender == UserGender.male,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    _GenderCard(
                      label: l10n.genderFemale,
                      icon: Icons.female,
                      value: UserGender.female,
                      selected: selectedGender == UserGender.female,
                      enabled: !isSaving,
                    ),
                    const SizedBox(height: 12),
                    _GenderCard(
                      label: l10n.genderPreferNotToSay,
                      icon: Icons.people_outline,
                      value: UserGender.none,
                      selected: selectedGender == UserGender.none,
                      enabled: !isSaving,
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: (selectedGender != null && !isSaving)
                          ? () => context
                              .read<GenderSelectionBloc>()
                              .add(const GenderSelectionConfirmed())
                          : null,
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.genderSelectionContinue),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.enabled,
  });

  final String label;
  final IconData icon;
  final UserGender value;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled
          ? () => context
              .read<GenderSelectionBloc>()
              .add(GenderOptionSelected(gender: value))
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.white,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: colorScheme.primary)
            else
              Icon(Icons.circle_outlined, color: colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}
