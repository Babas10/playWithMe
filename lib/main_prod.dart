import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/main_common.dart';

Future<void> main() async {
  EnvironmentConfig.setEnvironment(Environment.prod);
  await mainCommon();
}