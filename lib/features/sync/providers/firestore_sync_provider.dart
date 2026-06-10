import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore_sync_service.dart';


part 'firestore_sync_provider.g.dart';

// By naming the function 'firestoreSyncService', 
// Riverpod will generate a provider named 'firestoreSyncServiceProvider'
@Riverpod(keepAlive: true)
FirestoreSyncService firestoreSyncService(FirestoreSyncServiceRef ref) {
  return FirestoreSyncService(FirebaseFirestore.instance);
}