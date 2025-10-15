import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

/// Service for picking and cropping images from camera or gallery
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick an image from the specified source
  Future<File?> pickImage({
    required ImageSource source,
    bool cropSquare = true,
  }) async {
    try {
      // Pick image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null; // User cancelled
      }

      // Convert to File
      File imageFile = File(pickedFile.path);

      // Crop if requested
      if (cropSquare) {
        final croppedFile = await _cropImage(imageFile);
        if (croppedFile != null) {
          imageFile = croppedFile;
        }
      }

      return imageFile;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery({bool cropSquare = true}) async {
    return pickImage(source: ImageSource.gallery, cropSquare: cropSquare);
  }

  /// Pick image from camera
  Future<File?> pickFromCamera({bool cropSquare = true}) async {
    return pickImage(source: ImageSource.camera, cropSquare: cropSquare);
  }

  /// Crop an image to square aspect ratio
  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Avatar',
            toolbarColor: const Color(0xFF2196F3),
            toolbarWidgetColor: const Color(0xFFFFFFFF),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Avatar',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }

      return null;
    } catch (e) {
      // If cropping fails, return original image
      return imageFile;
    }
  }

  /// Validate image file size (max 5MB)
  bool validateFileSize(File file, {int maxSizeInMB = 5}) {
    final fileSizeInBytes = file.lengthSync();
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    return fileSizeInBytes <= maxSizeInBytes;
  }

  /// Validate image file extension
  bool validateFileExtension(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp'].contains(extension);
  }
}
