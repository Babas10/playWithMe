// Validates computeAccountStatus and computeDaysRemaining logic for grace period enforcement.
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/entities/account_status.dart';

void main() {
  group('computeAccountStatus', () {
    test('returns active when email is verified', () {
      final result = computeAccountStatus(
        isEmailVerified: true,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 100)),
      );
      expect(result, AccountStatus.active);
    });

    test('returns active when email is verified even with null createdAt', () {
      final result = computeAccountStatus(
        isEmailVerified: true,
        accountCreatedAt: null,
      );
      expect(result, AccountStatus.active);
    });

    test('returns pendingVerification when unverified and within 7 days', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(result, AccountStatus.pendingVerification);
    });

    test('returns pendingVerification when unverified and exactly 7 days', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(result, AccountStatus.pendingVerification);
    });

    test('returns pendingVerification when createdAt is null and unverified',
        () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: null,
      );
      expect(result, AccountStatus.pendingVerification);
    });

    test('returns pendingVerification for account created today', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now(),
      );
      expect(result, AccountStatus.pendingVerification);
    });

    test('returns restricted when unverified and 8-30 days old', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 15)),
      );
      expect(result, AccountStatus.restricted);
    });

    test('returns restricted when unverified and exactly 30 days old', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(result, AccountStatus.restricted);
    });

    test('returns scheduledForDeletion when unverified and over 30 days', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 31)),
      );
      expect(result, AccountStatus.scheduledForDeletion);
    });

    test('returns scheduledForDeletion for very old unverified accounts', () {
      final result = computeAccountStatus(
        isEmailVerified: false,
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 365)),
      );
      expect(result, AccountStatus.scheduledForDeletion);
    });
  });

  group('computeDaysRemaining', () {
    test('returns gracePeriodDays when accountCreatedAt is null', () {
      final result = computeDaysRemaining(accountCreatedAt: null);
      expect(result, gracePeriodDays);
    });

    test('returns 7 for account created today', () {
      final result = computeDaysRemaining(accountCreatedAt: DateTime.now());
      expect(result, 7);
    });

    test('returns correct days remaining within grace period', () {
      final result = computeDaysRemaining(
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      expect(result, 4);
    });

    test('returns 1 for account created 6 days ago', () {
      final result = computeDaysRemaining(
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 6)),
      );
      expect(result, 1);
    });

    test('returns 0 for account created exactly 7 days ago', () {
      final result = computeDaysRemaining(
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 7)),
      );
      expect(result, 0);
    });

    test('returns 0 for accounts past grace period', () {
      final result = computeDaysRemaining(
        accountCreatedAt: DateTime.now().subtract(const Duration(days: 15)),
      );
      expect(result, 0);
    });
  });

  group('AccountStatus enum', () {
    test('has all expected values', () {
      expect(AccountStatus.values, containsAll([
        AccountStatus.active,
        AccountStatus.pendingVerification,
        AccountStatus.restricted,
        AccountStatus.scheduledForDeletion,
      ]));
    });

    test('has exactly 4 values', () {
      expect(AccountStatus.values.length, 4);
    });
  });

  group('constants', () {
    test('gracePeriodDays is 7', () {
      expect(gracePeriodDays, 7);
    });

    test('deletionPeriodDays is 30', () {
      expect(deletionPeriodDays, 30);
    });
  });
}
