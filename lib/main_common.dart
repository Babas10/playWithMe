import 'package:flutter/material.dart';
import 'package:play_with_me/app/play_with_me_app.dart';
import 'package:play_with_me/core/services/service_locator.dart';

Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  runApp(const PlayWithMeApp());
}