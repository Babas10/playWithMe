import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

part 'user_search_result.freezed.dart';

/// Result of searching for a user by email
@freezed
class UserSearchResult with _$UserSearchResult {
  const factory UserSearchResult({
    UserEntity? user,
    required bool isFriend,
    required bool hasPendingRequest,
    String? requestDirection, // 'sent' | 'received'
  }) = _UserSearchResult;
}
