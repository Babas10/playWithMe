import 'dart:io';

/// Repository for managing image storage operations
abstract class ImageStorageRepository {
  /// Upload an avatar image for a user
  /// Returns the download URL of the uploaded image
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
    void Function(double progress)? onProgress,
  });

  /// Delete an avatar image for a user
  Future<void> deleteAvatar({
    required String userId,
  });

  /// Get the download URL for a user's avatar
  Future<String?> getAvatarUrl({
    required String userId,
  });
}
