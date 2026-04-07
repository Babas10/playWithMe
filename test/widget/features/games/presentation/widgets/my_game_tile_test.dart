// Widget tests for MyGameTile (Story 28.11).
// Validates tile rendering, status badge, and tap handler.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/my_game_item.dart';
import 'package:play_with_me/features/games/presentation/widgets/my_game_tile.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

MyGameItem _makeItem({
  GameStatus status = GameStatus.scheduled,
  String? invitationId,
  String groupName = '',
  MyGameItemSource source = MyGameItemSource.joined,
}) {
  return MyGameItem(
    gameId: 'game-1',
    source: source,
    invitationId: invitationId,
    title: 'Beach Volleyball',
    scheduledAt: DateTime.now().add(const Duration(days: 1)),
    locationName: 'Venice Beach',
    groupName: groupName,
    status: status,
  );
}

Widget _build(MyGameItem item, {VoidCallback? onTap}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(
      body: MyGameTile(
        item: item,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  group('MyGameTile', () {
    testWidgets('displays game title and location', (tester) async {
      await tester.pumpWidget(_build(_makeItem()));
      await tester.pump();

      expect(find.text('Beach Volleyball'), findsOneWidget);
      expect(find.textContaining('Venice Beach'), findsOneWidget);
    });

    testWidgets('shows Scheduled badge for scheduled game', (tester) async {
      await tester.pumpWidget(_build(_makeItem(status: GameStatus.scheduled)));
      await tester.pump();

      expect(find.text('Scheduled'), findsOneWidget);
    });

    testWidgets('shows Completed badge for completed game', (tester) async {
      await tester.pumpWidget(
          _build(_makeItem(status: GameStatus.completed)));
      await tester.pump();

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('shows Verification badge for verification game', (tester) async {
      await tester.pumpWidget(
          _build(_makeItem(status: GameStatus.verification)));
      await tester.pump();

      expect(find.text('Verification'), findsOneWidget);
    });

    testWidgets('shows group name when non-empty', (tester) async {
      await tester.pumpWidget(_build(_makeItem(groupName: 'Beach Crew')));
      await tester.pump();

      expect(find.text('Beach Crew'), findsOneWidget);
    });

    testWidgets('does not show group name when empty', (tester) async {
      await tester.pumpWidget(_build(_makeItem(groupName: '')));
      await tester.pump();

      expect(find.text(''), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_build(_makeItem(), onTap: () => tapped = true));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      expect(tapped, isTrue);
    });

    testWidgets('has chevron icon', (tester) async {
      await tester.pumpWidget(_build(_makeItem()));
      await tester.pump();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
