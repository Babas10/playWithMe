// Verifies that FirebaseImageStorageRepository handles avatar upload, deletion, and retrieval correctly

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/repositories/firebase_image_storage_repository.dart';

// Mocktail mocks
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}
class MockListResult extends Mock implements ListResult {}

void main() {
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late MockReference mockUserRef;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockSnapshot;
  late MockListResult mockListResult;
  late FirebaseImageStorageRepository repository;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    mockUserRef = MockReference();
    mockUploadTask = MockUploadTask();
    mockSnapshot = MockTaskSnapshot();
    mockListResult = MockListResult();
    repository = FirebaseImageStorageRepository(storage: mockStorage);

    // Register fallback values
    registerFallbackValue(File(''));
  });

  group('FirebaseImageStorageRepository', () {
    group('uploadAvatar', () {
      test('successfully uploads avatar and returns download URL', () async {
        // Arrange
        final testFile = File('test_avatar.jpg');
        const userId = 'user123';
        const downloadUrl = 'https://storage.example.com/avatar_123.jpg';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockUserRef);
        when(() => mockUserRef.putFile(any())).thenReturn(mockUploadTask);
        when(() => mockUploadTask.snapshotEvents).thenAnswer(
          (_) => Stream.value(mockSnapshot),
        );
        when(() => mockSnapshot.ref).thenReturn(mockUserRef);
        when(() => mockSnapshot.bytesTransferred).thenReturn(100);
        when(() => mockSnapshot.totalBytes).thenReturn(100);
        when(() => mockUserRef.getDownloadURL())
            .thenAnswer((_) async => downloadUrl);

        // Act
        final result = await repository.uploadAvatar(
          userId: userId,
          imageFile: testFile,
        );

        // Assert
        expect(result, downloadUrl);
        verify(() => mockStorage.ref()).called(1);
        verify(() => mockRef.child(any(that: contains('avatars/$userId'))))
            .called(1);
        verify(() => mockUserRef.putFile(testFile)).called(1);
        verify(() => mockUserRef.getDownloadURL()).called(1);
      });

      test('tracks upload progress when callback provided', () async {
        // Arrange
        final testFile = File('test_avatar.jpg');
        const userId = 'user123';
        const downloadUrl = 'https://storage.example.com/avatar_123.jpg';
        final progressValues = <double>[];

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockUserRef);
        when(() => mockUserRef.putFile(any())).thenReturn(mockUploadTask);

        // Simulate progress updates
        when(() => mockUploadTask.snapshotEvents).thenAnswer(
          (_) => Stream.fromIterable([
            mockSnapshot,
            mockSnapshot,
            mockSnapshot,
          ]),
        );

        when(() => mockSnapshot.bytesTransferred).thenReturn(50);
        when(() => mockSnapshot.totalBytes).thenReturn(100);
        when(() => mockSnapshot.ref).thenReturn(mockUserRef);
        when(() => mockUserRef.getDownloadURL())
            .thenAnswer((_) async => downloadUrl);

        // Act
        await repository.uploadAvatar(
          userId: userId,
          imageFile: testFile,
          onProgress: (progress) => progressValues.add(progress),
        );

        // Assert
        expect(progressValues, isNotEmpty);
        expect(progressValues.every((p) => p >= 0.0 && p <= 1.0), isTrue);
      });

      test('throws exception when Firebase upload fails', () async {
        // Arrange
        final testFile = File('test_avatar.jpg');
        const userId = 'user123';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child(any())).thenReturn(mockUserRef);
        when(() => mockUserRef.putFile(any()))
            .thenThrow(FirebaseException(plugin: 'storage', message: 'Upload failed'));

        // Act & Assert
        expect(
          () => repository.uploadAvatar(
            userId: userId,
            imageFile: testFile,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to upload avatar'),
          )),
        );
      });
    });

    group('deleteAvatar', () {
      test('successfully deletes all avatar files for user', () async {
        // Arrange
        const userId = 'user123';
        final mockItem1 = MockReference();
        final mockItem2 = MockReference();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(mockUserRef);
        when(() => mockUserRef.listAll()).thenAnswer((_) async => mockListResult);
        when(() => mockListResult.items).thenReturn([mockItem1, mockItem2]);
        when(() => mockItem1.delete()).thenAnswer((_) async {});
        when(() => mockItem2.delete()).thenAnswer((_) async {});

        // Act
        await repository.deleteAvatar(userId: userId);

        // Assert
        verify(() => mockUserRef.listAll()).called(1);
        verify(() => mockItem1.delete()).called(1);
        verify(() => mockItem2.delete()).called(1);
      });

      test('handles non-existent avatar folder gracefully', () async {
        // Arrange
        const userId = 'user123';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(mockUserRef);
        when(() => mockUserRef.listAll()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'object-not-found',
          ),
        );

        // Act & Assert - should not throw
        await repository.deleteAvatar(userId: userId);

        verify(() => mockUserRef.listAll()).called(1);
      });

      test('throws exception on other Firebase errors', () async {
        // Arrange
        const userId = 'user123';

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(mockUserRef);
        when(() => mockUserRef.listAll()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'permission-denied',
            message: 'Access denied',
          ),
        );

        // Act & Assert
        expect(
          () => repository.deleteAvatar(userId: userId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to delete avatar'),
          )),
        );
      });
    });

    group('getAvatarUrl', () {
      test('returns download URL when avatar exists', () async {
        // Arrange
        const userId = 'user123';
        const downloadUrl = 'https://storage.example.com/avatar_123.jpg';
        final mockItem = MockReference();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(mockUserRef);
        when(() => mockUserRef.listAll()).thenAnswer((_) async => mockListResult);
        when(() => mockListResult.items).thenReturn([mockItem]);
        when(() => mockItem.getDownloadURL()).thenAnswer((_) async => downloadUrl);

        // Act
        final result = await repository.getAvatarUrl(userId: userId);

        // Assert
        expect(result, downloadUrl);
        verify(() => mockUserRef.listAll()).called(1);
        verify(() => mockItem.getDownloadURL()).called(1);
      });

      test('returns null when no avatar exists', () async {
        // Arrange
        const userId = 'user123';
        final emptyListResult = MockListResult();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(mockUserRef);
        when(() => mockUserRef.listAll()).thenAnswer((_) async => emptyListResult);
        when(() => emptyListResult.items).thenReturn([]);

        // Act
        final result = await repository.getAvatarUrl(userId: userId);

        // Assert
        expect(result, isNull);
        verify(() => mockUserRef.listAll()).called(1);
      });

      test('returns null when avatar folder does not exist', () async {
        // Arrange
        const userId = 'user123';
        final notFoundRef = MockReference();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(notFoundRef);
        when(() => notFoundRef.listAll()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'object-not-found',
          ),
        );

        // Act
        final result = await repository.getAvatarUrl(userId: userId);

        // Assert
        expect(result, isNull);
        verify(() => notFoundRef.listAll()).called(1);
      });

      test('throws exception on other Firebase errors', () async {
        // Arrange
        const userId = 'user123';
        final errorRef = MockReference();

        when(() => mockStorage.ref()).thenReturn(mockRef);
        when(() => mockRef.child('avatars/$userId')).thenReturn(errorRef);
        when(() => errorRef.listAll()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'permission-denied',
            message: 'Access denied',
          ),
        );

        // Act & Assert
        expect(
          () => repository.getAvatarUrl(userId: userId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to get avatar URL'),
          )),
        );
      });
    });
  });
}
