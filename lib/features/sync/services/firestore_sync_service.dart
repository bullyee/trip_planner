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

  void buildPoiBatchOperations(WriteBatch batch, dynamic poi, String roiId) {
    final docRef = _db.collection('trips').doc(roiId).collection('pois').doc(poi.id);
    if (poi.isDeleted == true) {
      batch.delete(docRef);
    } else {
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
      return; 
    }

    await docRef.set({
      'id': roiId,
      'name': tripName,
      'authorId': userId,
      'members': [userId],
      'cloudVersion': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchUserTrips(String userId) {
    return _db
        .collection('trips')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<Map<String, dynamic>?> watchTrip(String roiId) {
    return _db
        .collection('trips')
        .doc(roiId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }
}
