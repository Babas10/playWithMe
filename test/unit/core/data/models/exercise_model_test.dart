// Validates ExerciseModel data structure, JSON serialization, and business logic methods.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/exercise_model.dart';

void main() {
  group('ExerciseModel', () {
    late ExerciseModel testExercise;

    setUp(() {
      testExercise = ExerciseModel(
        id: 'exercise-1',
        name: 'Serving Practice',
        description: 'Practice serving techniques',
        durationMinutes: 30,
        createdAt: DateTime(2024, 1, 1, 10, 0),
        updatedAt: DateTime(2024, 1, 1, 11, 0),
      );
    });

    group('Constructor', () {
      test('creates exercise with all fields', () {
        expect(testExercise.id, 'exercise-1');
        expect(testExercise.name, 'Serving Practice');
        expect(testExercise.description, 'Practice serving techniques');
        expect(testExercise.durationMinutes, 30);
        expect(testExercise.createdAt, DateTime(2024, 1, 1, 10, 0));
        expect(testExercise.updatedAt, DateTime(2024, 1, 1, 11, 0));
      });

      test('creates exercise with optional fields as null', () {
        final exercise = ExerciseModel(
          id: 'exercise-2',
          name: 'Drills',
          description: null,
          durationMinutes: null,
          createdAt: DateTime(2024, 1, 1),
        );

        expect(exercise.description, isNull);
        expect(exercise.durationMinutes, isNull);
        expect(exercise.updatedAt, isNull);
      });
    });

    group('JSON Serialization', () {
      test('toJson serializes correctly', () {
        final json = testExercise.toJson();

        expect(json['id'], 'exercise-1');
        expect(json['name'], 'Serving Practice');
        expect(json['description'], 'Practice serving techniques');
        expect(json['durationMinutes'], 30);
        expect(json['createdAt'], testExercise.createdAt.toIso8601String());
        expect(json['updatedAt'], testExercise.updatedAt?.toIso8601String());
      });

      test('fromJson deserializes correctly', () {
        final json = {
          'id': 'exercise-1',
          'name': 'Serving Practice',
          'description': 'Practice serving techniques',
          'durationMinutes': 30,
          'createdAt': '2024-01-01T10:00:00.000',
          'updatedAt': '2024-01-01T11:00:00.000',
        };

        final exercise = ExerciseModel.fromJson(json);

        expect(exercise.id, 'exercise-1');
        expect(exercise.name, 'Serving Practice');
        expect(exercise.description, 'Practice serving techniques');
        expect(exercise.durationMinutes, 30);
        expect(exercise.createdAt, DateTime(2024, 1, 1, 10, 0));
        expect(exercise.updatedAt, DateTime(2024, 1, 1, 11, 0));
      });

      test('toJson and fromJson are reversible', () {
        final json = testExercise.toJson();
        final exercise = ExerciseModel.fromJson(json);

        expect(exercise, testExercise);
      });
    });

    group('Firestore Conversion', () {
      test('toFirestore converts correctly', () {
        final firestoreData = testExercise.toFirestore();

        expect(firestoreData['id'], isNull); // ID is removed
        expect(firestoreData['name'], 'Serving Practice');
        expect(firestoreData['description'], 'Practice serving techniques');
        expect(firestoreData['durationMinutes'], 30);
        expect(firestoreData['createdAt'], isA<Timestamp>());
        expect(firestoreData['updatedAt'], isA<Timestamp>());
      });

      test('toFirestore removes id field', () {
        final firestoreData = testExercise.toFirestore();

        expect(firestoreData.containsKey('id'), isFalse);
      });

      test('toFirestore converts DateTime to Timestamp', () {
        final firestoreData = testExercise.toFirestore();

        final createdAtTimestamp = firestoreData['createdAt'] as Timestamp;
        expect(
          createdAtTimestamp.toDate(),
          testExercise.createdAt,
        );

        final updatedAtTimestamp = firestoreData['updatedAt'] as Timestamp;
        expect(
          updatedAtTimestamp.toDate(),
          testExercise.updatedAt,
        );
      });

      test('toFirestore handles null updatedAt', () {
        final exercise = testExercise.copyWith(updatedAt: null);
        final firestoreData = exercise.toFirestore();

        expect(firestoreData.containsKey('updatedAt'), isFalse);
      });
    });

    group('Business Logic Methods', () {
      group('hasDuration', () {
        test('returns true when duration is set and positive', () {
          expect(testExercise.hasDuration, isTrue);
        });

        test('returns false when duration is null', () {
          final exercise = testExercise.copyWith(durationMinutes: null);
          expect(exercise.hasDuration, isFalse);
        });

        test('returns false when duration is zero', () {
          final exercise = testExercise.copyWith(durationMinutes: 0);
          expect(exercise.hasDuration, isFalse);
        });
      });

      group('formattedDuration', () {
        test('returns "No duration set" when duration is null', () {
          final exercise = testExercise.copyWith(durationMinutes: null);
          expect(exercise.formattedDuration, 'No duration set');
        });

        test('formats minutes correctly', () {
          final exercise = testExercise.copyWith(durationMinutes: 30);
          expect(exercise.formattedDuration, '30 min');
        });

        test('formats hours correctly', () {
          final exercise = testExercise.copyWith(durationMinutes: 120);
          expect(exercise.formattedDuration, '2 h');
        });

        test('formats hours and minutes correctly', () {
          final exercise = testExercise.copyWith(durationMinutes: 150);
          expect(exercise.formattedDuration, '2 h 30 min');
        });

        test('formats single minute correctly', () {
          final exercise = testExercise.copyWith(durationMinutes: 1);
          expect(exercise.formattedDuration, '1 min');
        });
      });

      group('updateInfo', () {
        test('updates name', () {
          final updated = testExercise.updateInfo(name: 'New Name');
          expect(updated.name, 'New Name');
          expect(updated.description, testExercise.description);
          expect(updated.durationMinutes, testExercise.durationMinutes);
        });

        test('updates description', () {
          final updated =
              testExercise.updateInfo(description: 'New Description');
          expect(updated.description, 'New Description');
          expect(updated.name, testExercise.name);
          expect(updated.durationMinutes, testExercise.durationMinutes);
        });

        test('updates duration', () {
          final updated = testExercise.updateInfo(durationMinutes: 45);
          expect(updated.durationMinutes, 45);
          expect(updated.name, testExercise.name);
          expect(updated.description, testExercise.description);
        });

        test('updates all fields', () {
          final updated = testExercise.updateInfo(
            name: 'New Name',
            description: 'New Description',
            durationMinutes: 60,
          );

          expect(updated.name, 'New Name');
          expect(updated.description, 'New Description');
          expect(updated.durationMinutes, 60);
        });

        test('sets updatedAt to current time', () {
          final before = DateTime.now();
          final updated = testExercise.updateInfo(name: 'New Name');
          final after = DateTime.now();

          expect(updated.updatedAt, isNotNull);
          expect(updated.updatedAt!.isAfter(before) || updated.updatedAt!.isAtSameMomentAs(before), isTrue);
          expect(updated.updatedAt!.isBefore(after) || updated.updatedAt!.isAtSameMomentAs(after), isTrue);
        });

        test('does not modify original object', () {
          final original = testExercise.copyWith();
          testExercise.updateInfo(name: 'New Name');

          expect(testExercise.name, original.name);
        });
      });

      group('hasValidName', () {
        test('returns true for non-empty name', () {
          expect(testExercise.hasValidName, isTrue);
        });

        test('returns false for empty name', () {
          final exercise = testExercise.copyWith(name: '');
          expect(exercise.hasValidName, isFalse);
        });

        test('returns false for whitespace-only name', () {
          final exercise = testExercise.copyWith(name: '   ');
          expect(exercise.hasValidName, isFalse);
        });

        test('returns true for name with leading/trailing whitespace', () {
          final exercise = testExercise.copyWith(name: '  Valid  ');
          expect(exercise.hasValidName, isTrue);
        });
      });

      group('hasValidDuration', () {
        test('returns true when duration is null', () {
          final exercise = testExercise.copyWith(durationMinutes: null);
          expect(exercise.hasValidDuration, isTrue);
        });

        test('returns true for positive duration', () {
          final exercise = testExercise.copyWith(durationMinutes: 30);
          expect(exercise.hasValidDuration, isTrue);
        });

        test('returns true for duration at max limit (300)', () {
          final exercise = testExercise.copyWith(durationMinutes: 300);
          expect(exercise.hasValidDuration, isTrue);
        });

        test('returns false for zero duration', () {
          final exercise = testExercise.copyWith(durationMinutes: 0);
          expect(exercise.hasValidDuration, isFalse);
        });

        test('returns false for negative duration', () {
          final exercise = testExercise.copyWith(durationMinutes: -10);
          expect(exercise.hasValidDuration, isFalse);
        });

        test('returns false for duration above max limit (>300)', () {
          final exercise = testExercise.copyWith(durationMinutes: 301);
          expect(exercise.hasValidDuration, isFalse);
        });
      });
    });

    group('Copycontext', () {
      test('copyWith creates new instance with updated fields', () {
        final updated = testExercise.copyWith(name: 'Updated Name');

        expect(updated.name, 'Updated Name');
        expect(updated.id, testExercise.id);
        expect(updated.description, testExercise.description);
      });

      test('copyWith without arguments creates identical copy', () {
        final copy = testExercise.copyWith();

        expect(copy, testExercise);
      });
    });

    group('Equality', () {
      test('exercises with same values are equal', () {
        final exercise1 = ExerciseModel(
          id: 'exercise-1',
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        final exercise2 = ExerciseModel(
          id: 'exercise-1',
          name: 'Test',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(exercise1, equals(exercise2));
      });

      test('exercises with different values are not equal', () {
        final exercise1 = ExerciseModel(
          id: 'exercise-1',
          name: 'Test 1',
          createdAt: DateTime(2024, 1, 1),
        );

        final exercise2 = ExerciseModel(
          id: 'exercise-2',
          name: 'Test 2',
          createdAt: DateTime(2024, 1, 1),
        );

        expect(exercise1, isNot(equals(exercise2)));
      });
    });
  });
}
