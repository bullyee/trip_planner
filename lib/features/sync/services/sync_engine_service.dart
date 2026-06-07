import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';

class SyncEngineService {
  final AppDatabase localDb;
  final FirebaseFirestore firestore;
  final String currentUserId;
  
  StreamSubscription? _upstreamSub;

  SyncEngineService({
    required this.localDb,
    required this.firestore,
    required this.currentUserId,
  });

  /// Starts the bidirectional sync process.
  void startSync() {
    debugPrint('[SyncEngine] Starting real-time synchronization for user: $currentUserId');
    _startUpstreamSync();
  }

  /// Stops all active sync streams to prevent memory leaks.
  void stopSync() {
    debugPrint('[SyncEngine] Stopping synchronization');
    _upstreamSub?.cancel();
  }

  /// Pushes local unsynced data (isShared == false) to Firestore.
  /// Only POIs assigned to a specific ROI (Trip) are uploaded. Unassigned POIs remain local.
  void _startUpstreamSync() {
    _upstreamSub = localDb.watchUnsyncedPois().listen((unsyncedPois) async {
      
      // 1. [Sandbox Defense] Filter out local drafts. 
      // Only process POIs that have been explicitly added to a Trip (roiId != null).
      final poisToSync = unsyncedPois.where((poi) => poi.roiId != null).toList();

      if (poisToSync.isEmpty) return;

      for (final poi in poisToSync) {
        try {
          // 2. [Identity Correction] If the POI was created offline, reassign ownership 
          // from the placeholder 'guest_local_user' to the actual authenticated user.
          final realAuthorId = (poi.authorId == 'guest_local_user' || poi.authorId.isEmpty) 
              ? currentUserId 
              : poi.authorId;

          // Prepare the payload with the corrected author ID and a server timestamp.
          final payload = {
            'roiId': poi.roiId,
            'authorId': realAuthorId,
            'name': poi.name,
            'description': poi.description,
            'lat': poi.lat,
            'lng': poi.lng,
            'address': poi.address,
            'businessHours': poi.businessHours,
            'contactInfo': poi.contactInfo,
            'remoteCoverImageUrl': poi.remoteCoverImageUrl,
            'createdAt': poi.createdAt,
            'updatedAt': FieldValue.serverTimestamp(),
          };

          // 3. [Strict Routing] Upload exclusively to the collaborative Trip sub-collection.
          await firestore
              .collection('trips')
              .doc(poi.roiId)
              .collection('pois')
              .doc(poi.id)
              .set(payload, SetOptions(merge: true));
              
          debugPrint('[SyncEngine] Synced Collaborative POI: ${poi.name} to Trip: ${poi.roiId}');

          // 4. Mark as shared locally upon successful upload to prevent infinite loops.
          await localDb.markPoiAsShared(poi.id);
          
        } catch (e) {
          debugPrint('[SyncEngine] Failed to sync POI ${poi.name}: $e');
        }
      }
    });
  }
}

// Provider for injecting the SyncEngine globally
final syncEngineProvider = Provider<SyncEngineService>((ref) {
  final engine = SyncEngineService(
    localDb: ref.watch(databaseProvider),
    firestore: FirebaseFirestore.instance,
    currentUserId: ref.watch(currentUserIdProvider),
  );

  ref.onDispose(() {
    engine.stopSync();
  });

  return engine;
});