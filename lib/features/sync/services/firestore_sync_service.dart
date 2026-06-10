import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSyncService {
  final FirebaseFirestore _db;
  
  FirestoreSyncService(this._db);

  Future<bool> acquireLock(String roiId, String userId) async {
    final docRef = _db.collection('trips').doc(roiId);
    
    return await _db.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return false;
      
      final data = snapshot.data()!;
      final currentLock = data['syncLock'] as Map<String, dynamic>?;
      
      final now = Timestamp.now();
      if (currentLock != null) {
        final expiresAt = currentLock['expiresAt'] as Timestamp;
        if (expiresAt.compareTo(now) > 0 && currentLock['userId'] != userId) {
          return false; 
        }
      }
      
      transaction.update(docRef, {
        'syncLock': {
          'userId': userId,
          'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(seconds: 30))),
        }
      });
      return true;
    });
  }

  Future<void> releaseLock(String roiId) async {
    await _db.collection('trips').doc(roiId).update({
      'syncLock': FieldValue.delete()
    });
  }

  Future<int> fetchTripVersion(String roiId) async {
    final doc = await _db.collection('trips').doc(roiId).get();
    return (doc.data()?['cloudVersion'] as int?) ?? 0;
  }

  Future<bool> tripExists(String roiId) async {
    final doc = await _db.collection('trips').doc(roiId).get();
    return doc.exists;
  }

  WriteBatch createBatch() => _db.batch();

  void buildBatchOperations(WriteBatch batch, dynamic chunk, String roiId) {
    final docRef = _db.collection('trips').doc(roiId).collection('timeChunks').doc(chunk.id);
    
    if (chunk.isDeleted) {
      batch.delete(docRef);
    } else {
      batch.set(docRef, {
        'id': chunk.id,
        'poiId': chunk.poiId,
        'date': chunk.date,
        'startTime': chunk.startTime,
        'endTime': chunk.endTime,
        'status': chunk.status,
        'sortOrder': chunk.sortOrder,
        'duration': chunk.duration,
        'transitDuration': chunk.transitDuration,
        'isFixedTime': chunk.isFixedTime,
        'authorId': chunk.authorId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  /// POIs are pushed as a full snapshot (set+merge) rather than dirty-tracked,
  /// so this always writes the current local state. `localCoverImagePath` is
  /// intentionally omitted — it's a device-local file path, meaningless to
  /// other devices; only the remote URL is shared.
  void buildPoiBatchOperations(WriteBatch batch, dynamic poi, String roiId) {
    final docRef = _db.collection('trips').doc(roiId).collection('pois').doc(poi.id);
    batch.set(docRef, {
      'id': poi.id,
      'roiId': roiId,
      'authorId': poi.authorId,
      'name': poi.name,
      'description': poi.description,
      'address': poi.address,
      'lat': poi.lat,
      'lng': poi.lng,
      'businessHours': poi.businessHours,
      'contactInfo': poi.contactInfo,
      'remoteCoverImageUrl': poi.remoteCoverImageUrl,
      'sortOrder': poi.sortOrder,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> fetchTripPois(String roiId) async {
    final snapshot = await _db.collection('trips').doc(roiId).collection('pois').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  void appendVersionBumpAndLockRelease(WriteBatch batch, String roiId, int newVersion) {
    final docRef = _db.collection('trips').doc(roiId);
    batch.update(docRef, {
      'cloudVersion': newVersion,
      'syncLock': FieldValue.delete(),
    });
  }

  Future<void> commitBatch(WriteBatch batch) => batch.commit();

  Future<List<Map<String, dynamic>>> fetchTripData(String roiId) async {
    final snapshot = await _db.collection('trips').doc(roiId).collection('timeChunks').get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> initializeCloudTrip(String roiId, String userId, String tripName) async {
    final docRef = _db.collection('trips').doc(roiId);
    
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      // Already initialized on the cloud. 
      // Could happen if another user invited them, but locally it wasn't marked shared yet.
      return; 
    }

    await docRef.set({
      'id': roiId,
      'name': tripName, // Optional metadata for cloud listing
      'authorId': userId,
      'members': [userId], // Critical for Firestore Security Rules
      'cloudVersion': 0,   // Start at 0 so the first local push (local==0) is
                           // not rejected as obsolete; that push bumps it to 1.
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

