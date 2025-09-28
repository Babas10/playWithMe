#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Firebase Project Tracker - Story 0.2.1
///
/// This tool helps track and verify Firebase project creation progress.
/// It provides functionality to:
/// - Record project IDs securely
/// - Verify project creation status
/// - Generate status reports
/// - Validate project configuration

void main(List<String> args) async {
  print('🔥 Firebase Project Tracker - Story 0.2.1');
  print('==========================================\n');

  if (args.isEmpty) {
    printUsage();
    return;
  }

  final command = args.first;

  switch (command) {
    case '--record':
      await recordProjects();
      break;
    case '--status':
      await showStatus();
      break;
    case '--verify':
      await verifyProjects();
      break;
    case '--help':
      printUsage();
      break;
    default:
      print('❌ Unknown command: $command');
      printUsage();
  }
}

void printUsage() {
  print('Usage: dart run tools/firebase_project_tracker.dart [COMMAND]');
  print('');
  print('Commands:');
  print('  --record    Record Firebase project IDs interactively');
  print('  --status    Show current project creation status');
  print('  --verify    Verify all required projects are documented');
  print('  --help      Show this help message');
  print('');
  print('This tool helps track the Firebase projects required for Story 0.2.1:');
  print('  - playwithme-dev (Development)');
  print('  - playwithme-stg (Staging)');
  print('  - playwithme-prod (Production)');
}

Future<void> recordProjects() async {
  print('📝 Recording Firebase Project Information');
  print('========================================\n');

  final projectData = <String, dynamic>{
    'story': '0.2.1',
    'created_at': DateTime.now().toIso8601String(),
    'projects': <String, dynamic>{},
  };

  const environments = ['dev', 'stg', 'prod'];
  const environmentNames = {
    'dev': 'Development',
    'stg': 'Staging',
    'prod': 'Production',
  };

  for (final env in environments) {
    print('🏗️  ${environmentNames[env]} Environment');
    print('Expected project ID: playwithme-$env\n');

    stdout.write('Have you created the Firebase project for $env? (y/n): ');
    final created = stdin.readLineSync()?.toLowerCase();

    if (created == 'y' || created == 'yes') {
      stdout.write('Enter the actual project ID: ');
      final projectId = stdin.readLineSync()?.trim();

      if (projectId?.isNotEmpty == true) {
        projectData['projects'][env] = {
          'project_id': projectId,
          'expected_id': 'playwithme-$env',
          'matches_expected': projectId == 'playwithme-$env',
          'created_at': DateTime.now().toIso8601String(),
          'status': 'created',
        };
        print('✅ Recorded: $projectId\n');
      } else {
        print('⚠️  Skipped: No project ID provided\n');
      }
    } else {
      projectData['projects'][env] = {
        'expected_id': 'playwithme-$env',
        'status': 'pending',
        'created_at': null,
      };
      print('📋 Marked as pending\n');
    }
  }

  // Save to file
  final configFile = File('.firebase_projects.json');
  await configFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(projectData),
  );

  print('💾 Project information saved to .firebase_projects.json');
  print('   (This file is gitignored for security)');

  await showSummary(projectData);
}

Future<void> showStatus() async {
  print('📊 Firebase Project Status');
  print('=========================\n');

  final configFile = File('.firebase_projects.json');

  if (!await configFile.exists()) {
    print('❌ No project tracking file found.');
    print('   Run --record first to document your projects.\n');
    return;
  }

  try {
    final content = await configFile.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    await showSummary(data);
  } catch (e) {
    print('❌ Error reading project tracking file: $e');
  }
}

Future<void> showSummary(Map<String, dynamic> data) async {
  final projects = data['projects'] as Map<String, dynamic>? ?? {};
  var createdCount = 0;
  var totalCount = 3;

  print('\n📋 Project Status Summary');
  print('========================');

  const environments = ['dev', 'stg', 'prod'];
  const environmentNames = {
    'dev': 'Development',
    'stg': 'Staging',
    'prod': 'Production',
  };

  for (final env in environments) {
    final project = projects[env] as Map<String, dynamic>?;
    final status = project?['status'] ?? 'not_started';
    final projectId = project?['project_id'];
    final matchesExpected = project?['matches_expected'] ?? false;

    print('\n🏗️  ${environmentNames[env]} (${env.toUpperCase()})');

    switch (status) {
      case 'created':
        print('   Status: ✅ Created');
        print('   Project ID: $projectId');
        if (matchesExpected) {
          print('   ID Match: ✅ Matches expected');
        } else {
          print('   ID Match: ⚠️  Different from expected (playwithme-$env)');
        }
        createdCount++;
        break;
      case 'pending':
        print('   Status: 📋 Pending creation');
        print('   Expected: playwithme-$env');
        break;
      default:
        print('   Status: ❌ Not started');
        print('   Expected: playwithme-$env');
    }
  }

  print('\n' + '=' * 40);
  print('Progress: $createdCount/$totalCount projects created');

  if (createdCount == totalCount) {
    print('🎉 All Firebase projects created!');
    print('   Ready to proceed with Story 0.2.2');
  } else {
    print('📋 ${totalCount - createdCount} projects still need to be created');
    print('   See FIREBASE_PROJECT_CREATION_GUIDE.md for instructions');
  }
}

Future<void> verifyProjects() async {
  print('🔍 Verifying Firebase Project Configuration');
  print('==========================================\n');

  final configFile = File('.firebase_projects.json');

  if (!await configFile.exists()) {
    print('❌ No project tracking file found.');
    print('   Run --record first to document your projects.');
    exit(1);
  }

  try {
    final content = await configFile.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final projects = data['projects'] as Map<String, dynamic>;

    var allValid = true;
    const environments = ['dev', 'stg', 'prod'];

    for (final env in environments) {
      final project = projects[env] as Map<String, dynamic>?;

      if (project == null || project['status'] != 'created') {
        print('❌ $env environment: Project not created');
        allValid = false;
        continue;
      }

      final projectId = project['project_id'] as String;
      final matchesExpected = project['matches_expected'] as bool? ?? false;

      print('✅ $env environment: $projectId');

      if (!matchesExpected) {
        print('   ⚠️  Project ID differs from expected (playwithme-$env)');
        print('   ℹ️  You\'ll need to update Flutter configuration accordingly');
      }
    }

    print('\n' + '=' * 50);

    if (allValid) {
      print('✅ Verification successful!');
      print('   All required Firebase projects are documented.');
      print('   Story 0.2.1 Definition of Done: ✅ COMPLETE');
      exit(0);
    } else {
      print('❌ Verification failed!');
      print('   Some Firebase projects are missing.');
      print('   Complete project creation before proceeding.');
      exit(1);
    }

  } catch (e) {
    print('❌ Error during verification: $e');
    exit(1);
  }
}