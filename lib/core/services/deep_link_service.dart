// Abstract service for handling deep links and extracting invite tokens.
abstract class DeepLinkService {
  Stream<String?> get inviteTokenStream;
  Future<String?> getInitialInviteToken();
  void dispose();
}
