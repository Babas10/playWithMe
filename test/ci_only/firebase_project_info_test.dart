import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/models/firebase_project_info.dart';

void main() {
  group('FirebaseProjectInfo', () {
    test('should create instance with required fields', () {
      final projectInfo = FirebaseProjectInfo(
        environment: 'dev',
        expectedProjectId: 'gatherli-dev',
        status: FirebaseProjectStatus.created,
      );

      expect(projectInfo.environment, 'dev');
      expect(projectInfo.expectedProjectId, 'gatherli-dev');
      expect(projectInfo.status, FirebaseProjectStatus.created);
      expect(projectInfo.matchesExpected, false); // default value
      expect(projectInfo.actualProjectId, null);
      expect(projectInfo.createdAt, null);
    });

    test('should create instance with all fields', () {
      final createdAt = DateTime.now();
      final projectInfo = FirebaseProjectInfo(
        environment: 'prod',
        expectedProjectId: 'gatherli-prod',
        actualProjectId: 'gatherli-prod',
        status: FirebaseProjectStatus.created,
        createdAt: createdAt,
        matchesExpected: true,
      );

      expect(projectInfo.environment, 'prod');
      expect(projectInfo.expectedProjectId, 'gatherli-prod');
      expect(projectInfo.actualProjectId, 'gatherli-prod');
      expect(projectInfo.status, FirebaseProjectStatus.created);
      expect(projectInfo.matchesExpected, true);
      expect(projectInfo.createdAt, createdAt);
    });

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        final projectInfo = FirebaseProjectInfo(
          environment: 'dev',
          expectedProjectId: 'gatherli-dev',
          actualProjectId: 'gatherli-dev-custom',
          status: FirebaseProjectStatus.created,
          matchesExpected: false,
        );

        final json = projectInfo.toJson();

        expect(json['environment'], 'dev');
        expect(json['expectedProjectId'], 'gatherli-dev');
        expect(json['actualProjectId'], 'gatherli-dev-custom');
        expect(json['status'], 'created');
        expect(json['matchesExpected'], false);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'environment': 'dev',
          'expectedProjectId': 'gatherli-dev',
          'actualProjectId': 'gatherli-dev',
          'status': 'created',
          'matchesExpected': true,
        };

        final projectInfo = FirebaseProjectInfo.fromJson(json);

        expect(projectInfo.environment, 'dev');
        expect(projectInfo.expectedProjectId, 'gatherli-dev');
        expect(projectInfo.actualProjectId, 'gatherli-dev');
        expect(projectInfo.status, FirebaseProjectStatus.created);
        expect(projectInfo.matchesExpected, true);
      });
    });
  });

  group('FirebaseProjectTracker', () {
    test('should create tracker with projects', () {
      final trackedAt = DateTime.now();
      final projects = [
        FirebaseProjectInfo(
          environment: 'dev',
          expectedProjectId: 'gatherli-dev',
          status: FirebaseProjectStatus.created,
        ),
        FirebaseProjectInfo(
          environment: 'prod',
          expectedProjectId: 'gatherli-prod',
          status: FirebaseProjectStatus.pending,
        ),
      ];

      final tracker = FirebaseProjectTracker(
        storyVersion: '0.2.1',
        trackedAt: trackedAt,
        projects: projects,
      );

      expect(tracker.storyVersion, '0.2.1');
      expect(tracker.trackedAt, trackedAt);
      expect(tracker.projects.length, 2);
      expect(tracker.projects.first.environment, 'dev');
    });

    group('JSON serialization', () {
      test('should serialize tracker to JSON correctly', () {
        final trackedAt = DateTime.parse('2024-01-01T12:00:00Z');
        final projects = [
          FirebaseProjectInfo(
            environment: 'dev',
            expectedProjectId: 'gatherli-dev',
            status: FirebaseProjectStatus.created,
          ),
        ];

        final tracker = FirebaseProjectTracker(
          storyVersion: '0.2.1',
          trackedAt: trackedAt,
          projects: projects,
        );

        final json = tracker.toJson();

        expect(json['storyVersion'], '0.2.1');
        expect(json['trackedAt'], '2024-01-01T12:00:00.000Z');
        expect(json['projects'], isA<List>());
        expect((json['projects'] as List).length, 1);
      });

      test('should deserialize tracker from JSON correctly', () {
        final json = {
          'storyVersion': '0.2.1',
          'trackedAt': '2024-01-01T12:00:00.000Z',
          'projects': [
            {
              'environment': 'dev',
              'expectedProjectId': 'gatherli-dev',
              'status': 'created',
              'matchesExpected': true,
            }
          ],
        };

        final tracker = FirebaseProjectTracker.fromJson(json);

        expect(tracker.storyVersion, '0.2.1');
        expect(tracker.trackedAt, DateTime.parse('2024-01-01T12:00:00.000Z'));
        expect(tracker.projects.length, 1);
        expect(tracker.projects.first.environment, 'dev');
      });
    });
  });

  group('FirebaseProjectStatus', () {
    test('should have correct display names', () {
      expect(FirebaseProjectStatus.notStarted.displayName, 'Not Started');
      expect(FirebaseProjectStatus.pending.displayName, 'Pending');
      expect(FirebaseProjectStatus.created.displayName, 'Created');
      expect(FirebaseProjectStatus.error.displayName, 'Error');
    });

    test('should have correct emojis', () {
      expect(FirebaseProjectStatus.notStarted.emoji, '❌');
      expect(FirebaseProjectStatus.pending.emoji, '📋');
      expect(FirebaseProjectStatus.created.emoji, '✅');
      expect(FirebaseProjectStatus.error.emoji, '🚫');
    });

    test('should serialize to correct JSON values', () {
      expect(FirebaseProjectStatus.notStarted.name, 'notStarted');
      expect(FirebaseProjectStatus.pending.name, 'pending');
      expect(FirebaseProjectStatus.created.name, 'created');
      expect(FirebaseProjectStatus.error.name, 'error');
    });
  });

  group('Gatherli Requirements', () {
    test('should support all required project environments', () {
      const requiredEnvironments = ['dev', 'prod'];
      const expectedProjectIds = [
        'gatherli-dev',
        'gatherli-prod',
      ];

      final projects = List.generate(2, (index) {
        return FirebaseProjectInfo(
          environment: requiredEnvironments[index],
          expectedProjectId: expectedProjectIds[index],
          status: FirebaseProjectStatus.created,
        );
      });

      expect(projects.length, 2);
      expect(projects.map((p) => p.environment).toList(), requiredEnvironments);
      expect(projects.map((p) => p.expectedProjectId).toList(), expectedProjectIds);
    });

    test('should validate completion criteria', () {
      final allCreated = [
        FirebaseProjectInfo(
          environment: 'dev',
          expectedProjectId: 'gatherli-dev',
          actualProjectId: 'gatherli-dev',
          status: FirebaseProjectStatus.created,
          matchesExpected: true,
        ),
        FirebaseProjectInfo(
          environment: 'prod',
          expectedProjectId: 'gatherli-prod',
          actualProjectId: 'gatherli-prod',
          status: FirebaseProjectStatus.created,
          matchesExpected: true,
        ),
      ];

      // All projects created
      final allComplete = allCreated.every((p) => p.status == FirebaseProjectStatus.created);
      expect(allComplete, true);

      // All project IDs match expected
      final allMatch = allCreated.every((p) => p.matchesExpected);
      expect(allMatch, true);

      expect(allComplete && allMatch, true);
    });
  });
}
