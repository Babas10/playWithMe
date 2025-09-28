#!/usr/bin/env dart

import 'dart:io';

/// Helper script to replace Firebase configuration files
///
/// This script guides the user through the process of replacing
/// placeholder Firebase configuration files with real ones.

void main(List<String> args) async {
  print('🔥 Firebase Configuration Replacement Helper');
  print('===========================================\n');

  if (args.isNotEmpty && args.first == '--help') {
    printUsage();
    return;
  }

  print('This script will help you replace placeholder Firebase configuration files');
  print('with real ones downloaded from Firebase Console.\n');

  // Check prerequisites
  print('📋 Checking prerequisites...');
  if (!await checkPrerequisites()) {
    return;
  }

  // Guide through replacement process
  print('\n🔄 Starting replacement process...');
  await guideReplacementProcess();

  print('\n✅ Replacement process complete!');
  print('Run "dart run tools/validate_firebase_config.dart" to validate your configurations.');
}

void printUsage() {
  print('Usage: dart run tools/replace_firebase_configs.dart');
  print('');
  print('This interactive script helps you replace placeholder Firebase');
  print('configuration files with real ones from your Firebase projects.');
  print('');
  print('Prerequisites:');
  print('  - Firebase projects created: playwithme-dev, playwithme-stg, playwithme-prod');
  print('  - Configuration files downloaded from Firebase Console');
}

Future<bool> checkPrerequisites() async {
  var allGood = true;

  // Check if placeholder files exist
  const configFiles = [
    'android/app/src/dev/google-services.json',
    'android/app/src/stg/google-services.json',
    'android/app/src/prod/google-services.json',
    'ios/Runner/Firebase/dev/GoogleService-Info.plist',
    'ios/Runner/Firebase/stg/GoogleService-Info.plist',
    'ios/Runner/Firebase/prod/GoogleService-Info.plist',
  ];

  for (final configFile in configFiles) {
    final file = File(configFile);
    if (!await file.exists()) {
      print('  ❌ Missing placeholder file: $configFile');
      allGood = false;
    } else {
      print('  ✅ Found placeholder file: $configFile');
    }
  }

  if (!allGood) {
    print('\n❌ Some placeholder files are missing.');
    print('Make sure you\'re running this from the project root directory.');
    return false;
  }

  return true;
}

Future<void> guideReplacementProcess() async {
  print('\n📱 Android Configuration Replacement');
  print('====================================');

  await replaceAndroidConfigs();

  print('\n🍎 iOS Configuration Replacement');
  print('===============================');

  await replaceiOSConfigs();
}

Future<void> replaceAndroidConfigs() async {
  const environments = ['dev', 'stg', 'prod'];
  const projectNames = {
    'dev': 'playwithme-dev',
    'stg': 'playwithme-stg',
    'prod': 'playwithme-prod',
  };

  for (final env in environments) {
    final targetPath = 'android/app/src/$env/google-services.json';
    final projectName = projectNames[env];

    print('\n📁 $env Environment ($projectName)');
    print('  Target: $targetPath');

    print('  Steps:');
    print('    1. Go to Firebase Console → $projectName → Project Settings');
    print('    2. Select your Android app');
    print('    3. Download google-services.json');
    print('    4. Replace the file at: $targetPath');

    stdout.write('  Have you replaced this file? (y/n): ');
    final response = stdin.readLineSync()?.toLowerCase();

    if (response == 'y' || response == 'yes') {
      print('  ✅ Marked as replaced');
    } else {
      print('  ⚠️  Skipped - remember to replace this file later');
    }
  }
}

Future<void> replaceiOSConfigs() async {
  const environments = ['dev', 'stg', 'prod'];
  const projectNames = {
    'dev': 'playwithme-dev',
    'stg': 'playwithme-stg',
    'prod': 'playwithme-prod',
  };

  for (final env in environments) {
    final targetPath = 'ios/Runner/Firebase/$env/GoogleService-Info.plist';
    final projectName = projectNames[env];

    print('\n📁 $env Environment ($projectName)');
    print('  Target: $targetPath');

    print('  Steps:');
    print('    1. Go to Firebase Console → $projectName → Project Settings');
    print('    2. Select your iOS app');
    print('    3. Download GoogleService-Info.plist');
    print('    4. Replace the file at: $targetPath');

    stdout.write('  Have you replaced this file? (y/n): ');
    final response = stdin.readLineSync()?.toLowerCase();

    if (response == 'y' || response == 'yes') {
      print('  ✅ Marked as replaced');
    } else {
      print('  ⚠️  Skipped - remember to replace this file later');
    }
  }
}