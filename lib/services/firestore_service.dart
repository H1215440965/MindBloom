import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user is currently logged in.');
    }

    return user.uid;
  }

  Future<void> saveMoodCheckIn(String mood) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('moodCheckins')
        .add({
      'mood': mood,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveJournalEntry({
    required String content,
    required String mood,
    required List<String> tags,
    bool isDraft = false,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .add({
      'content': content,
      'mood': mood,
      'tags': tags,
      'isDraft': isDraft,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getJournalEntries() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMoodCheckIns() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('moodCheckins')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteJournalEntry(String docId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .doc(docId)
        .delete();
  }

  Future<void> saveReminderSettings({
    required bool enabled,
    required String time,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc('settings')
        .set({
      'enabled': enabled,
      'time': time,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}