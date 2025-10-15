import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:play_with_me/core/domain/repositories/image_storage_repository.dart';

/// Firebase implementation of image storage repository
class FirebaseImageStorageRepository implements ImageStorageRepository {
  final FirebaseStorage _storage;

  FirebaseImageStorageRepository({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final filename = 'avatar_$timestamp.$extension';

      // Create reference to avatars/{userId}/{filename}
      final ref = _storage.ref().child('avatars/$userId/$filename');

      // Upload the file
      final uploadTask = ref.putFile(imageFile);

      // Listen to upload progress if callback provided
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get and return the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload avatar: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<void> deleteAvatar({
    required String userId,
  }) async {
    try {
      // List all files in the user's avatar folder
      final ref = _storage.ref().child('avatars/$userId');
      final listResult = await ref.listAll();

      // Delete all files in the folder
      for (final item in listResult.items) {
        await item.delete();
      }
    } on FirebaseException catch (e) {
      // Ignore if folder doesn't exist
      if (e.code != 'object-not-found') {
        throw Exception('Failed to delete avatar: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  @override
  Future<String?> getAvatarUrl({
    required String userId,
  }) async {
    try {
      // List all files in the user's avatar folder
      final ref = _storage.ref().child('avatars/$userId');
      final listResult = await ref.listAll();

      // Return the download URL of the first (most recent) avatar
      if (listResult.items.isNotEmpty) {
        return await listResult.items.first.getDownloadURL();
      }

      return null;
    } on FirebaseException catch (e) {
      // Return null if folder doesn't exist
      if (e.code == 'object-not-found') {
        return null;
      }
      throw Exception('Failed to get avatar URL: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get avatar URL: $e');
    }
  }
}
