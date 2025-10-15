import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';
import 'package:play_with_me/core/services/service_locator.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/avatar_upload/avatar_upload_state.dart';

/// Widget for uploading and managing user avatar
class AvatarUploadWidget extends StatelessWidget {
  final String? currentPhotoUrl;
  final ValueChanged<String?> onPhotoUrlChanged;
  final bool enabled;

  const AvatarUploadWidget({
    super.key,
    this.currentPhotoUrl,
    required this.onPhotoUrlChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AvatarUploadBloc(
        imageStorageRepository: sl<ImageStorageRepository>(),
        imagePickerService: sl<ImagePickerService>(),
        authRepository: context.read<AuthRepository>(),
      )..add(const AvatarUploadEvent.started()),
      child: BlocListener<AvatarUploadBloc, AvatarUploadState>(
        listener: (context, state) {
          if (state is AvatarUploadUploadSuccess) {
            // Notify parent widget of new photo URL
            onPhotoUrlChanged(state.downloadUrl);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar uploaded successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Reset the bloc
            context.read<AvatarUploadBloc>().add(const AvatarUploadEvent.reset());
          } else if (state is AvatarUploadUploadError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AvatarUploadValidationError) {
            // Show validation error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is AvatarUploadDeleteSuccess) {
            // Notify parent widget that photo was deleted
            onPhotoUrlChanged(null);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar removed successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Reset the bloc
            context.read<AvatarUploadBloc>().add(const AvatarUploadEvent.reset());
          } else if (state is AvatarUploadDeleteError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _AvatarUploadContent(
          currentPhotoUrl: currentPhotoUrl,
          enabled: enabled,
        ),
      ),
    );
  }
}

/// Private widget containing the avatar upload UI
class _AvatarUploadContent extends StatelessWidget {
  final String? currentPhotoUrl;
  final bool enabled;

  const _AvatarUploadContent({
    this.currentPhotoUrl,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvatarUploadBloc, AvatarUploadState>(
      builder: (context, state) {
        final isUploading = state is AvatarUploadUploading;
        final isPicked = state is AvatarUploadPicked;
        final uploadProgress = state is AvatarUploadUploading ? state.progress : 0.0;

        // Determine which image to display
        File? pickedImage;
        if (state is AvatarUploadPicked) {
          pickedImage = state.imageFile;
        } else if (state is AvatarUploadUploading) {
          pickedImage = state.imageFile;
        }

        return Column(
          children: [
            // Avatar preview
            Stack(
              children: [
                // Avatar image
                if (pickedImage != null)
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: FileImage(pickedImage),
                  )
                else if (currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: NetworkImage(currentPhotoUrl!),
                    onBackgroundImageError: (_, __) {
                      // Handle image load error silently
                    },
                  )
                else
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.person,
                      size: 56,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),

                // Upload progress overlay
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: uploadProgress,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(uploadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Camera button overlay
                if (!isUploading && enabled)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () => _showImageSourceDialog(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons for picked image
            if (isPicked && enabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      context.read<AvatarUploadBloc>().add(
                            const AvatarUploadEvent.uploadCancelled(),
                          );
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<AvatarUploadBloc>().add(
                            const AvatarUploadEvent.uploadRequested(),
                          );
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload'),
                  ),
                ],
              ),

            // Delete button if current photo exists
            if (!isPicked && !isUploading && currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty && enabled)
              TextButton.icon(
                onPressed: () => _showDeleteConfirmation(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remove Avatar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Show dialog to select image source (camera or gallery)
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.read<AvatarUploadBloc>().add(
                      const AvatarUploadEvent.imageSourceSelected(
                        source: ImageSource.camera,
                      ),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                context.read<AvatarUploadBloc>().add(
                      const AvatarUploadEvent.imageSourceSelected(
                        source: ImageSource.gallery,
                      ),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () {
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show confirmation dialog before deleting avatar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Avatar'),
        content: const Text('Are you sure you want to remove your avatar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AvatarUploadBloc>().add(
                    const AvatarUploadEvent.deleteRequested(),
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
