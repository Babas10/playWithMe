import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

abstract class GenderSelectionEvent extends Equatable {
  const GenderSelectionEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on login/registration to check if the user needs to select gender.
class CheckGenderSelection extends GenderSelectionEvent {
  const CheckGenderSelection({required this.uid});

  final String uid;

  @override
  List<Object?> get props => [uid];
}

/// User tapped one of the three gender cards.
class GenderOptionSelected extends GenderSelectionEvent {
  const GenderOptionSelected({required this.gender});

  final UserGender gender;

  @override
  List<Object?> get props => [gender];
}

/// User tapped the Continue button to confirm the selection.
class GenderSelectionConfirmed extends GenderSelectionEvent {
  const GenderSelectionConfirmed();
}
