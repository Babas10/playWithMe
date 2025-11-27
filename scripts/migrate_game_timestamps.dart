// Script to migrate game scheduledAt from String to Timestamp
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase (you'll need to update with your config)
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  print('🔄 Starting migration of game timestamps...');

  // Get all games
  final gamesSnapshot = await firestore.collection('games').get();

  print('📊 Found ${gamesSnapshot.docs.length} games to check');

  int migratedCount = 0;
  int errorCount = 0;

  for (var doc in gamesSnapshot.docs) {
    try {
      final data = doc.data();
      final scheduledAt = data['scheduledAt'];

      // Check if scheduledAt is a String (needs migration)
      if (scheduledAt is String) {
        print('🔧 Migrating game ${doc.id}: $scheduledAt (String) → Timestamp');

        // Parse the ISO string to DateTime
        final dateTime = DateTime.parse(scheduledAt);

        // Convert to Timestamp
        final timestamp = Timestamp.fromDate(dateTime);

        // Update the document
        await doc.reference.update({
          'scheduledAt': timestamp,
          'updatedAt': Timestamp.now(),
        });

        migratedCount++;
        print('✅ Migrated game ${doc.id}');
      } else if (scheduledAt is Timestamp) {
        print('⏭️  Game ${doc.id} already has Timestamp, skipping');
      } else {
        print('⚠️  Game ${doc.id} has unexpected type: ${scheduledAt.runtimeType}');
      }
    } catch (e) {
      print('❌ Error migrating game ${doc.id}: $e');
      errorCount++;
    }
  }

  print('');
  print('✅ Migration complete!');
  print('   Migrated: $migratedCount games');
  print('   Errors: $errorCount');
  print('   Total: ${gamesSnapshot.docs.length} games');
}
