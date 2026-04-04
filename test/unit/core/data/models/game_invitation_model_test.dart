// Tests GameInvitationModel serialization and business logic (Story 28.1)
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_invitation_model.dart';

void main() {
  group('GameInvitationModel', () {
    GameInvitationModel createTestInvitation({
      String id = 'inv-123',
      String gameId = 'game-123',
      String groupId = 'group-123',
      String inviteeId = 'invitee-user',
      String inviterId = 'inviter-user',
      GameInvitationStatus status = GameInvitationStatus.pending,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? expiresAt,
    }) {
      return GameInvitationModel(
        id: id,
        gameId: gameId,
        groupId: groupId,
        inviteeId: inviteeId,
        inviterId: inviterId,
        status: status,
        createdAt: createdAt ?? DateTime(2025),
        updatedAt: updatedAt,
        expiresAt: expiresAt,
      );
    }

    group('defaults', () {
      test('status defaults to pending', () {
        final inv = GameInvitationModel(
          id: 'i',
          gameId: 'g',
          groupId: 'grp',
          inviteeId: 'invitee',
          inviterId: 'inviter',
          createdAt: DateTime(2025),
        );
        expect(inv.status, GameInvitationStatus.pending);
      });
    });

    group('isPending', () {
      test('returns true for pending status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.pending);
        expect(inv.isPending, isTrue);
      });

      test('returns false for accepted status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.accepted);
        expect(inv.isPending, isFalse);
      });

      test('returns false for declined status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.declined);
        expect(inv.isPending, isFalse);
      });

      test('returns false for expired status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.expired);
        expect(inv.isPending, isFalse);
      });
    });

    group('isAccepted', () {
      test('returns true for accepted status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.accepted);
        expect(inv.isAccepted, isTrue);
      });

      test('returns false for pending status', () {
        final inv = createTestInvitation(status: GameInvitationStatus.pending);
        expect(inv.isAccepted, isFalse);
      });
    });

    group('JSON serialization', () {
      test('serializes and deserializes all required fields', () {
        final inv = createTestInvitation();
        final json = inv.toJson();

        expect(json['gameId'], 'game-123');
        expect(json['groupId'], 'group-123');
        expect(json['inviteeId'], 'invitee-user');
        expect(json['inviterId'], 'inviter-user');
        expect(json['status'], 'pending');

        final restored = GameInvitationModel.fromJson(json);
        expect(restored.gameId, inv.gameId);
        expect(restored.inviteeId, inv.inviteeId);
        expect(restored.inviterId, inv.inviterId);
        expect(restored.status, inv.status);
      });

      test('serializes accepted status correctly', () {
        final inv = createTestInvitation(status: GameInvitationStatus.accepted);
        expect(inv.toJson()['status'], 'accepted');
      });

      test('serializes declined status correctly', () {
        final inv = createTestInvitation(status: GameInvitationStatus.declined);
        expect(inv.toJson()['status'], 'declined');
      });

      test('serializes expired status correctly', () {
        final inv = createTestInvitation(status: GameInvitationStatus.expired);
        expect(inv.toJson()['status'], 'expired');
      });
    });

    group('copyWith', () {
      test('updates status while preserving other fields', () {
        final inv = createTestInvitation(status: GameInvitationStatus.pending);
        final accepted = inv.copyWith(
          status: GameInvitationStatus.accepted,
          updatedAt: DateTime(2025, 6),
        );
        expect(accepted.status, GameInvitationStatus.accepted);
        expect(accepted.gameId, inv.gameId);
        expect(accepted.inviteeId, inv.inviteeId);
      });
    });
  });
}
