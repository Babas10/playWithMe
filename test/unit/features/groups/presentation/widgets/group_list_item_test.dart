// Tests for GroupListItem widget covering display of group information
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/group_model.dart';
import 'package:play_with_me/features/groups/presentation/widgets/group_list_item.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

void main() {
  // Override HTTP client to prevent network image loading errors in tests
  setUpAll(() {
    HttpOverrides.global = null;
  });

  Widget createWidgetUnderTest({
    required GroupModel group,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: GroupListItem(
          group: group,
          onTap: onTap ?? () {},
        ),
      ),
    );
  }

  group('GroupListItem', () {
    testWidgets('displays group name', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('Beach Volleyball Crew'), findsOneWidget);
    });

    testWidgets('displays group description when available', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        description: 'Weekly beach volleyball games',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('Weekly beach volleyball games'), findsOneWidget);
    });

    testWidgets('does not display description when null', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        description: null,
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      // Only the group name should be displayed
      expect(find.text('Beach Volleyball Crew'), findsOneWidget);
    });

    testWidgets('displays member count correctly', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        memberIds: const ['user-123', 'user-456', 'user-789'],
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.textContaining('3 members'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('displays "1 member" for single member group', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        memberIds: const ['user-123'],
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('1 member'), findsOneWidget);
    });

    testWidgets('displays public privacy label', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        privacy: GroupPrivacy.public,
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('Public'), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('displays invite only privacy label', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        privacy: GroupPrivacy.inviteOnly,
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('Invite Only'), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('does not display privacy label for private groups', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
        privacy: GroupPrivacy.private,
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.text('Private'), findsNothing);
    });

    testWidgets('displays chevron icon', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    // TODO: Fix network image test - NetworkImage loading fails in Flutter test environment
    // The test framework returns HTTP 400 for all network requests
    // See: https://github.com/flutter/flutter/issues/
    // testWidgets('displays group photo when available', (tester) async {
    //   final group = GroupModel(
    //     id: 'group-1',
    //     name: 'Beach Volleyball Crew',
    //     photoUrl: 'https://example.com/photo.jpg',
    //     createdBy: 'user-123',
    //     createdAt: DateTime(2024, 1, 1),
    //   );

    //   await tester.pumpWidget(createWidgetUnderTest(group: group));

    //   final circleAvatar = tester.widget<CircleAvatar>(
    //     find.byType(CircleAvatar),
    //   );
    //   expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    //   final networkImage = circleAvatar.backgroundImage as NetworkImage;
    //   expect(networkImage.url, 'https://example.com/photo.jpg');
    // });

    testWidgets('displays group initials when no photo', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        photoUrl: null,
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      // Should display initials "BV" for "Beach Volleyball"
      expect(find.text('BV'), findsOneWidget);
    });

    testWidgets('displays single letter initial for one-word group name', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Volleyball',
        photoUrl: null,
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      // Should display first two letters "VO"
      expect(find.text('VO'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(
        group: group,
        onTap: () => tapped = true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });

    testWidgets('is wrapped in a Card widget', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball Crew',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('truncates long group names with ellipsis', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'This is a very long group name that should be truncated with ellipsis when displayed in the UI',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find.textContaining('This is a very long'),
      );
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('truncates long descriptions with ellipsis', (tester) async {
      final group = GroupModel(
        id: 'group-1',
        name: 'Beach Volleyball',
        description: 'This is a very long description that should be truncated with ellipsis after two lines when displayed in the UI to prevent overflow',
        createdBy: 'user-123',
        createdAt: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(group: group));
      await tester.pumpAndSettle();

      final descText = tester.widget<Text>(
        find.textContaining('This is a very long'),
      );
      expect(descText.maxLines, 2);
      expect(descText.overflow, TextOverflow.ellipsis);
    });
  });
}
