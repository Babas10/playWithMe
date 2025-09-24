import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/service_locator.dart';

void main() {
  setUp(() async {
    EnvironmentConfig.setEnvironment(Environment.prod);
    await initializeDependencies();
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('PlayWithMe app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PlayWithMeApp());

    expect(find.text('PlayWithMe'), findsOneWidget);
    expect(find.text('Welcome to PlayWithMe!'), findsOneWidget);
    expect(find.text('Beach volleyball games organizer'), findsOneWidget);
    expect(find.text('Environment: Production'), findsOneWidget);
    expect(find.text('Firebase Project: playwithme-prod'), findsOneWidget);
  });
}
