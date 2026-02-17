// Stores and retrieves pending invite tokens using SharedPreferences.
import 'package:shared_preferences/shared_preferences.dart';

class PendingInviteStorage {
  static const String _key = 'pending_invite_token';
  static const String _consumedKey = 'consumed_invite_token';

  final SharedPreferences _prefs;

  PendingInviteStorage({required SharedPreferences prefs}) : _prefs = prefs;

  Future<void> store(String token) async {
    await _prefs.setString(_key, token);
  }

  Future<String?> retrieve() async {
    return _prefs.getString(_key);
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  /// Mark a token as consumed so it won't be re-processed on hot restart.
  Future<void> markConsumed(String token) async {
    await _prefs.setString(_consumedKey, token);
  }

  /// Check if a token has already been consumed.
  bool isConsumed(String token) {
    return _prefs.getString(_consumedKey) == token;
  }
}
