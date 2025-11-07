// Tests for MyCommunityPage to verify UI rendering and interactions
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_bloc.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_event.dart';
import 'package:play_with_me/features/friends/presentation/bloc/friend_state.dart';
import 'package:play_with_me/features/friends/presentation/widgets/friends_list.dart';
import 'package:play_with_me/features/friends/presentation/widgets/friend_requests_list.dart';

class MockFriendBloc extends Mock implements FriendBloc {}

// Test widget wrapper
class TestMyCommunityPage extends StatelessWidget {
  const TestMyCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Community'),
        centerTitle: true,
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Friends'),
            Tab(text: 'Requests'),
          ],
        ),
      ),
      body: BlocListener<FriendBloc, FriendState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            loaded: (friends, receivedRequests, sentRequests) {},
            searchResult: (user, isFriend, hasPendingRequest, requestDirection) {},
            statusResult: (status) {},
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                ),
              );
            },
            actionSuccess: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
        },
        child: BlocBuilder<FriendBloc, FriendState>(
          builder: (context, state) {
            return state.maybeWhen(
              initial: () => const Center(child: Text('Loading...')),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (friends, receivedRequests, sentRequests) {
                return DefaultTabController(
                  length: 2,
                  child: TabBarView(
                    children: [
                      FriendsList(
                        friends: friends,
                        onRemoveFriend: (friendshipId) {},
                      ),
                      FriendRequestsList(
                        receivedRequests: receivedRequests,
                        sentRequests: sentRequests,
                        onAcceptRequest: (friendshipId) {},
                        onDeclineRequest: (friendshipId) {},
                        onCancelRequest: (friendshipId) {},
                      ),
                    ],
                  ),
                );
              },
              error: (message) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading friends'),
                      const SizedBox(height: 8),
                      Text(message),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          context.read<FriendBloc>().add(
                                const FriendEvent.loadRequested(),
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  late MockFriendBloc mockFriendBloc;

  setUp(() {
    mockFriendBloc = MockFriendBloc();
  });

  setUpAll(() {
    registerFallbackValue(const FriendEvent.loadRequested());
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: BlocProvider<FriendBloc>.value(
          value: mockFriendBloc,
          child: child,
        ),
      ),
    );
  }

  group('MyCommunityPage', () {
    testWidgets('displays loading indicator when state is loading',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state)
          .thenReturn(const FriendState.loading());
      when(() => mockFriendBloc.stream)
          .thenAnswer((_) => Stream.value(const FriendState.loading()));

      await tester.pumpWidget(
        createTestWidget(const TestMyCommunityPage()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays tabs (Friends and Requests)',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        )),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      expect(find.text('Friends'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('displays friends list when loaded',
        (WidgetTester tester) async {
      final testFriend = UserEntity(
        uid: 'friend-1',
        email: 'friend@example.com',
        displayName: 'Friend User',
        isEmailVerified: true,
        isAnonymous: false,
      );

      when(() => mockFriendBloc.state).thenReturn(
        FriendState.loaded(
          friends: [testFriend],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(FriendState.loaded(
          friends: [testFriend],
          receivedRequests: [],
          sentRequests: [],
        )),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      expect(find.text('Friend User'), findsOneWidget);
      expect(find.text('friend@example.com'), findsOneWidget);
    });

    testWidgets('displays empty state when no friends',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        )),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      expect(find.text('You don\'t have any friends yet'), findsOneWidget);
      expect(find.text('Search for friends to get started!'), findsOneWidget);
    });

    testWidgets('displays received requests in Requests tab',
        (WidgetTester tester) async {
      final testRequest = FriendshipEntity(
        id: 'friendship-1',
        initiatorId: 'friend-id',
        recipientId: 'test-id',
        initiatorName: 'Friend User',
        recipientName: 'Test User',
        status: FriendshipStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockFriendBloc.state).thenReturn(
        FriendState.loaded(
          friends: [],
          receivedRequests: [testRequest],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(FriendState.loaded(
          friends: [],
          receivedRequests: [testRequest],
          sentRequests: [],
        )),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      // Switch to Requests tab
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Received Requests'), findsOneWidget);
      expect(find.text('Friend User'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('displays sent requests in Requests tab',
        (WidgetTester tester) async {
      final testRequest = FriendshipEntity(
        id: 'friendship-1',
        initiatorId: 'test-id',
        recipientId: 'friend-id',
        initiatorName: 'Test User',
        recipientName: 'Friend User',
        status: FriendshipStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(() => mockFriendBloc.state).thenReturn(
        FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [testRequest],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [testRequest],
        )),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      // Switch to Requests tab
      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Sent Requests'), findsOneWidget);
      expect(find.text('Friend User'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('displays error state with retry button',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.error(message: 'Failed to load friends'),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(
          const FriendState.error(message: 'Failed to load friends'),
        ),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      expect(find.text('Error loading friends'), findsOneWidget);
      expect(find.text('Failed to load friends'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button triggers loadRequested event',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.error(message: 'Failed to load friends'),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.value(
          const FriendState.error(message: 'Failed to load friends'),
        ),
      );
      when(() => mockFriendBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockFriendBloc.add(const FriendEvent.loadRequested()))
          .called(1);
    });

    testWidgets('shows snackbar on error state',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
          const FriendState.error(message: 'Something went wrong'),
        ]),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));
      await tester.pump();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is SnackBar &&
            widget.backgroundColor == Colors.red),
        findsOneWidget,
      );
    });

    testWidgets('shows success snackbar on actionSuccess state',
        (WidgetTester tester) async {
      when(() => mockFriendBloc.state).thenReturn(
        const FriendState.loaded(
          friends: [],
          receivedRequests: [],
          sentRequests: [],
        ),
      );
      when(() => mockFriendBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          const FriendState.loaded(
            friends: [],
            receivedRequests: [],
            sentRequests: [],
          ),
          const FriendState.actionSuccess(
            message: 'Friend request sent successfully',
          ),
        ]),
      );

      await tester.pumpWidget(createTestWidget(const TestMyCommunityPage()));
      await tester.pump();

      expect(find.text('Friend request sent successfully'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is SnackBar &&
            widget.backgroundColor == Colors.green),
        findsOneWidget,
      );
    });
  });
}
