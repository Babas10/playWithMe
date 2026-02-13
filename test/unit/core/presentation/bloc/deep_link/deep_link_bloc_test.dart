// Validates DeepLinkBloc emits correct states during initialization, token reception, and clearing.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_event.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_state.dart';
import 'package:play_with_me/core/services/deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

class MockDeepLinkService extends Mock implements DeepLinkService {}

class MockPendingInviteStorage extends Mock implements PendingInviteStorage {}

void main() {
  late MockDeepLinkService mockDeepLinkService;
  late MockPendingInviteStorage mockStorage;

  setUp(() {
    mockDeepLinkService = MockDeepLinkService();
    mockStorage = MockPendingInviteStorage();
  });

  DeepLinkBloc buildBloc() {
    return DeepLinkBloc(
      deepLinkService: mockDeepLinkService,
      pendingInviteStorage: mockStorage,
    );
  }

  group('DeepLinkBloc', () {
    test('initial state is DeepLinkInitial', () {
      when(() => mockDeepLinkService.inviteTokenStream)
          .thenAnswer((_) => const Stream.empty());
      final bloc = buildBloc();
      expect(bloc.state, const DeepLinkInitial());
      bloc.close();
    });

    group('InitializeDeepLinks', () {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits [DeepLinkPendingInvite] when stored token exists',
        setUp: () {
          when(() => mockStorage.retrieve())
              .thenAnswer((_) async => 'stored-token');
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => const Stream.empty());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeDeepLinks()),
        expect: () => [
          const DeepLinkPendingInvite(token: 'stored-token'),
        ],
        verify: (_) {
          verify(() => mockStorage.retrieve()).called(1);
          verifyNever(() => mockDeepLinkService.getInitialInviteToken());
        },
      );

      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits [DeepLinkPendingInvite] when initial deep link token exists',
        setUp: () {
          when(() => mockStorage.retrieve()).thenAnswer((_) async => null);
          when(() => mockDeepLinkService.getInitialInviteToken())
              .thenAnswer((_) async => 'initial-token');
          when(() => mockStorage.store('initial-token'))
              .thenAnswer((_) async {});
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => const Stream.empty());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeDeepLinks()),
        expect: () => [
          const DeepLinkPendingInvite(token: 'initial-token'),
        ],
        verify: (_) {
          verify(() => mockStorage.store('initial-token')).called(1);
        },
      );

      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits [DeepLinkNoInvite] when no stored or initial token exists',
        setUp: () {
          when(() => mockStorage.retrieve()).thenAnswer((_) async => null);
          when(() => mockDeepLinkService.getInitialInviteToken())
              .thenAnswer((_) async => null);
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => const Stream.empty());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeDeepLinks()),
        expect: () => [
          const DeepLinkNoInvite(),
        ],
      );

      blocTest<DeepLinkBloc, DeepLinkState>(
        'listens to foreground token stream after initialization',
        setUp: () {
          when(() => mockStorage.retrieve()).thenAnswer((_) async => null);
          when(() => mockDeepLinkService.getInitialInviteToken())
              .thenAnswer((_) async => null);
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => Stream.value('stream-token'));
          when(() => mockStorage.store('stream-token'))
              .thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeDeepLinks()),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const DeepLinkNoInvite(),
          const DeepLinkPendingInvite(token: 'stream-token'),
        ],
      );
    });

    group('InviteTokenReceived', () {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits [DeepLinkPendingInvite] and stores token',
        setUp: () {
          when(() => mockStorage.store('new-token'))
              .thenAnswer((_) async {});
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => const Stream.empty());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InviteTokenReceived('new-token')),
        expect: () => [
          const DeepLinkPendingInvite(token: 'new-token'),
        ],
        verify: (_) {
          verify(() => mockStorage.store('new-token')).called(1);
        },
      );
    });

    group('ClearPendingInvite', () {
      blocTest<DeepLinkBloc, DeepLinkState>(
        'emits [DeepLinkNoInvite] and clears storage',
        setUp: () {
          when(() => mockStorage.clear()).thenAnswer((_) async {});
          when(() => mockDeepLinkService.inviteTokenStream)
              .thenAnswer((_) => const Stream.empty());
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const ClearPendingInvite()),
        expect: () => [
          const DeepLinkNoInvite(),
        ],
        verify: (_) {
          verify(() => mockStorage.clear()).called(1);
        },
      );
    });
  });
}
