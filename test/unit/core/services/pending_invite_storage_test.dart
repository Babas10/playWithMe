// Validates PendingInviteStorage stores, retrieves, and clears tokens correctly.
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late PendingInviteStorage storage;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    storage = PendingInviteStorage(prefs: mockPrefs);
  });

  group('PendingInviteStorage', () {
    const testToken = 'abc123def456';
    const key = 'pending_invite_token';

    group('store', () {
      test('stores token in SharedPreferences', () async {
        when(() => mockPrefs.setString(key, testToken))
            .thenAnswer((_) async => true);

        await storage.store(testToken);

        verify(() => mockPrefs.setString(key, testToken)).called(1);
      });
    });

    group('retrieve', () {
      test('returns stored token when one exists', () async {
        when(() => mockPrefs.getString(key)).thenReturn(testToken);

        final result = await storage.retrieve();

        expect(result, testToken);
        verify(() => mockPrefs.getString(key)).called(1);
      });

      test('returns null when no token is stored', () async {
        when(() => mockPrefs.getString(key)).thenReturn(null);

        final result = await storage.retrieve();

        expect(result, isNull);
      });
    });

    group('clear', () {
      test('removes token from SharedPreferences', () async {
        when(() => mockPrefs.remove(key)).thenAnswer((_) async => true);

        await storage.clear();

        verify(() => mockPrefs.remove(key)).called(1);
      });
    });
  });
}
