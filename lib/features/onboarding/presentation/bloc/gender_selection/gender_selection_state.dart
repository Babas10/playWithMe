import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

abstract class GenderSelectionState extends Equatable {
  const GenderSelectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state — check not triggered yet.
class GenderSelectionInitial extends GenderSelectionState {
  const GenderSelectionInitial();
}

/// Fetching the user's Firestore document to determine if gender is set.
class GenderSelectionChecking extends GenderSelectionState {
  const GenderSelectionChecking();
}

/// User has no gender set — show the selection screen.
class GenderSelectionRequired extends GenderSelectionState {
  const GenderSelectionRequired({this.selectedGender, required this.uid});

  final UserGender? selectedGender;
  final String uid;

  @override
  List<Object?> get props => [selectedGender, uid];
}

/// User already has a gender set — skip the screen.
class GenderSelectionNotRequired extends GenderSelectionState {
  const GenderSelectionNotRequired();
}

/// Saving the selected gender to Firestore.
class GenderSelectionSaving extends GenderSelectionState {
  const GenderSelectionSaving();
}

/// Gender saved successfully — proceed to home.
class GenderSelectionSaved extends GenderSelectionState {
  const GenderSelectionSaved();
}

/// An error occurred while checking or saving.
class GenderSelectionError extends GenderSelectionState {
  const GenderSelectionError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
