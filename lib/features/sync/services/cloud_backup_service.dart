import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cloud_backup_service.g.dart';

@Riverpod(keepAlive: true)
CloudSyncService cloudSyncService(CloudSyncServiceRef ref) {
  return CloudSyncService(
    db: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: FirebaseStorage.instance,
  );
}

class CloudSyncService {
  CloudSyncService({
    required this.db,
    required this.auth,
    required this.storage,
  });

  final FirebaseFirestore db;
  final FirebaseAuth auth;
  final FirebaseStorage storage;

  static const int _currentBackupVersion = 1;

  /// Uploads the local SQLite JSON export to Firebase Storage
  /// and updates the metadata in Firestore.
  Future<void> backupToCloud(Map<String, dynamic> tripData) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Cannot sync: User is not signed in.');
    }

    final jsonString = jsonEncode(tripData);
    final storageRef = storage.ref().child('users/${user.uid}/backups/latest.json');
    
    // 1. Upload the heavy JSON blob to Firebase Storage to bypass 1MiB Firestore limit
    await storageRef.putString(
      jsonString,
      format: PutStringFormat.raw,
      metadata: SettableMetadata(contentType: 'application/json'),
    );

    // 2. Write lightweight metadata to Firestore
    final docRef = db
        .collection('users')
        .doc(user.uid)
        .collection('backups')
        .doc('latest');

    await docRef.set({
      'lastSyncedAt': FieldValue.serverTimestamp(),
      'version': _currentBackupVersion,
      'devicePlatform': kIsWeb ? 'web' : 'native',
      'byteSize': jsonString.length,
    });
  }

  /// Downloads the latest JSON backup from Firebase Storage after validating metadata.
  Future<Map<String, dynamic>?> restoreFromCloud() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Cannot restore: User is not signed in.');
    }

    // 1. Fetch metadata to check existence and version
    final docRef = db
        .collection('users')
        .doc(user.uid)
        .collection('backups')
        .doc('latest');

    final snapshot = await docRef.get();

    if (!snapshot.exists || snapshot.data() == null) {
      return null; // No backup found
    }

    final metadata = snapshot.data()!;
    final version = metadata['version'] as int?;

    // Version guard to prevent parsing incompatible schema
    if (version == null || version > _currentBackupVersion) {
      throw Exception('Backup version ($version) is incompatible with this app version ($_currentBackupVersion). Please update the app.');
    }

    // 2. Fetch the actual JSON payload from Firebase Storage
    final storageRef = storage.ref().child('users/${user.uid}/backups/latest.json');
    
    // Utilize a reasonable memory limit (e.g., 50MB) for the download
    const int maxBytes = 50 * 1024 * 1024; 
    final bytes = await storageRef.getData(maxBytes);

    if (bytes == null) {
      throw Exception('Backup metadata exists, but file is missing in Storage.');
    }

    final jsonString = utf8.decode(bytes);
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
}