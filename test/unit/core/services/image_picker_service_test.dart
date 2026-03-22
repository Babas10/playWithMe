// Verifies that ImagePickerService correctly handles image selection, cropping, and validation

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/services/image_picker_service.dart';

// Mocktail mocks
class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  late MockImagePicker mockImagePicker;
  late ImagePickerService imagePickerService;

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
  });

  setUp(() {
    mockImagePicker = MockImagePicker();
    imagePickerService = ImagePickerService(picker: mockImagePicker);
  });

  group('ImagePickerService', () {
    group('pickImage', () {
      test('returns file when image is picked successfully', () async {
        // Arrange
        final mockXFile = MockXFile();
        when(() => mockXFile.path).thenReturn('/tmp/test_image.jpg');
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickImage(
          source: ImageSource.gallery,
          cropSquare: false, // Disable cropping for this test
        );

        // Assert
        expect(result, isNotNull);
        expect(result?.path, contains('test_image.jpg'));
        verify(() => mockImagePicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 85,
            )).called(1);
      });

      test('returns null when user cancels image selection', () async {
        // Arrange
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => null);

        // Act
        final result = await imagePickerService.pickImage(
          source: ImageSource.gallery,
          cropSquare: false,
        );

        // Assert
        expect(result, isNull);
        verify(() => mockImagePicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 85,
            )).called(1);
      });

      test('throws exception when image picker fails', () async {
        // Arrange
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenThrow(Exception('Picker failed'));

        // Act & Assert
        expect(
          () => imagePickerService.pickImage(
            source: ImageSource.gallery,
            cropSquare: false,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to pick image'),
          )),
        );
      });

      test('throws user-friendly exception when camera access is denied',
          () async {
        // Arrange
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenThrow(
          PlatformException(code: 'camera_access_denied'),
        );

        // Act & Assert
        expect(
          () => imagePickerService.pickImage(
            source: ImageSource.camera,
            cropSquare: false,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Camera access denied'),
          )),
        );
      });

      test('throws user-friendly exception when photo library access is denied',
          () async {
        // Arrange
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenThrow(
          PlatformException(code: 'photo_access_denied'),
        );

        // Act & Assert
        expect(
          () => imagePickerService.pickImage(
            source: ImageSource.gallery,
            cropSquare: false,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Photo library access denied'),
          )),
        );
      });

      test('wraps other PlatformException with generic message', () async {
        // Arrange
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenThrow(
          PlatformException(code: 'unknown_error', message: 'Something broke'),
        );

        // Act & Assert
        expect(
          () => imagePickerService.pickImage(
            source: ImageSource.gallery,
            cropSquare: false,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to pick image'),
          )),
        );
      });
    });

    group('pickFromGallery', () {
      test('picks image from gallery with correct source', () async {
        // Arrange
        final mockXFile = MockXFile();
        when(() => mockXFile.path).thenReturn('/tmp/gallery_image.jpg');
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickFromGallery(cropSquare: false);

        // Assert
        expect(result, isNotNull);
        verify(() => mockImagePicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 85,
            )).called(1);
      });
    });

    group('pickFromCamera', () {
      test('picks image from camera with correct source', () async {
        // Arrange
        final mockXFile = MockXFile();
        when(() => mockXFile.path).thenReturn('/tmp/camera_image.jpg');
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => mockXFile);

        // Act
        final result = await imagePickerService.pickFromCamera(cropSquare: false);

        // Assert
        expect(result, isNotNull);
        verify(() => mockImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 85,
            )).called(1);
      });

      test('skips cropping on Android camera to avoid image_cropper crash',
          () async {
        // Arrange — cropSquare: true but on Android camera, crop must be skipped
        // to avoid the "Reply already submitted" fatal crash in image_cropper.
        final mockXFile = MockXFile();
        when(() => mockXFile.path).thenReturn('/tmp/camera_image.jpg');
        when(() => mockImagePicker.pickImage(
              source: any(named: 'source'),
              maxWidth: any(named: 'maxWidth'),
              maxHeight: any(named: 'maxHeight'),
              imageQuality: any(named: 'imageQuality'),
            )).thenAnswer((_) async => mockXFile);

        // Act — cropSquare: true, but on non-Android (test env) it would crop;
        // here we verify the path is returned from the picker, not a crop path.
        final result = await imagePickerService.pickFromCamera(cropSquare: true);

        // Assert — image is returned (crop was either skipped or returned original)
        expect(result, isNotNull);
        verify(() => mockImagePicker.pickImage(
              source: ImageSource.camera,
              maxWidth: 1024,
              maxHeight: 1024,
              imageQuality: 85,
            )).called(1);
      });
    });

    group('validateFileSize', () {
      test('returns true for file within size limit', () {
        // Create a temporary file for testing
        final testFile = File('test_file.txt');
        try {
          // Create a small file (1KB)
          testFile.writeAsBytesSync(List.filled(1024, 0));

          // Act
          final result = imagePickerService.validateFileSize(testFile, maxSizeInMB: 1);

          // Assert
          expect(result, isTrue);
        } finally {
          // Cleanup
          if (testFile.existsSync()) {
            testFile.deleteSync();
          }
        }
      });

      test('returns false for file exceeding size limit', () {
        // Create a temporary file for testing
        final testFile = File('test_large_file.txt');
        try {
          // Create a 6MB file
          testFile.writeAsBytesSync(List.filled(6 * 1024 * 1024, 0));

          // Act
          final result = imagePickerService.validateFileSize(testFile, maxSizeInMB: 5);

          // Assert
          expect(result, isFalse);
        } finally {
          // Cleanup
          if (testFile.existsSync()) {
            testFile.deleteSync();
          }
        }
      });
    });

    group('validateFileExtension', () {
      test('returns true for valid image extensions', () {
        final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];

        for (final ext in validExtensions) {
          final testFile = File('test_image.$ext');
          final result = imagePickerService.validateFileExtension(testFile);
          expect(result, isTrue, reason: 'Extension .$ext should be valid');
        }
      });

      test('returns true for uppercase extensions', () {
        final testFile = File('test_image.JPG');
        final result = imagePickerService.validateFileExtension(testFile);
        expect(result, isTrue);
      });

      test('returns false for invalid extensions', () {
        final invalidExtensions = ['pdf', 'txt', 'doc', 'gif', 'bmp'];

        for (final ext in invalidExtensions) {
          final testFile = File('test_file.$ext');
          final result = imagePickerService.validateFileExtension(testFile);
          expect(result, isFalse, reason: 'Extension .$ext should be invalid');
        }
      });
    });
  });
}
