import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  Future<void> addMood(String mood) async {
    await _db.collection('users').doc(uid).collection('moods').add({
      'mood': mood,
      'date': Timestamp.now(),
    });
  }

  Future<void> addJournal(String text) async {
    await _db.collection('users').doc(uid).collection('journals').add({
      'text': text,
      'date': Timestamp.now(),
    });
  }
}