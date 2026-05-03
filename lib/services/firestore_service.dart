import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyInsightsResult {
  WeeklyInsightsResult({
    required this.summary,
    required this.suggestion,
    required this.checkInCount,
    required this.journalCount,
    required this.moodCounts,
  });

  final String summary;
  final String suggestion;
  final int checkInCount;
  final int journalCount;
  final Map<String, int> moodCounts;
}

class ReminderSettingsData {
  ReminderSettingsData({required this.enabled, required this.time24h});

  final bool enabled;

  /// 24h "HH:mm" stored in Firestore (e.g. "20:00").
  final String time24h;
}

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

  /// Last [days] days of mood check-ins and journal saves (non-draft count for journals).
  Future<WeeklyInsightsResult> getWeeklyInsights({int days = 7}) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceTs = Timestamp.fromDate(since);

    final moodsSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('moodCheckins')
        .where('createdAt', isGreaterThanOrEqualTo: sinceTs)
        .get();

    final journalSnap = await _db
        .collection('users')
        .doc(uid)
        .collection('journalEntries')
        .where('createdAt', isGreaterThanOrEqualTo: sinceTs)
        .get();

    final moodCounts = <String, int>{};
    for (final doc in moodsSnap.docs) {
      final m = doc.data()['mood']?.toString() ?? 'Unknown';
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }

    var journalCount = 0;
    for (final doc in journalSnap.docs) {
      final draft = doc.data()['isDraft'];
      if (draft != true) journalCount++;
    }

    final checkInCount = moodsSnap.docs.length;

    final summary = _buildWeeklySummary(
      moodCounts: moodCounts,
      checkInCount: checkInCount,
      journalCount: journalCount,
      days: days,
    );
    final suggestion = _buildWeeklySuggestion(moodCounts: moodCounts);

    return WeeklyInsightsResult(
      summary: summary,
      suggestion: suggestion,
      checkInCount: checkInCount,
      journalCount: journalCount,
      moodCounts: moodCounts,
    );
  }

  String _buildWeeklySummary({
    required Map<String, int> moodCounts,
    required int checkInCount,
    required int journalCount,
    required int days,
  }) {
    if (checkInCount == 0 && journalCount == 0) {
      return 'No mood check-ins or completed journal entries in the last $days days. '
          'Log your mood on Home and save a journal entry to see patterns here.';
    }

    final parts = <String>[];
    if (checkInCount > 0) {
      final top = _topMood(moodCounts);
      parts.add(
        'Mood check-ins: $checkInCount. Most common mood: $top.',
      );
    } else {
      parts.add('No mood check-ins in this window yet.');
    }
    parts.add('Completed journal entries: $journalCount.');
    return parts.join('\n\n');
  }

  String _topMood(Map<String, int> moodCounts) {
    if (moodCounts.isEmpty) return '—';
    final entries = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final e = entries.first;
    return '${e.key} (${e.value}×)';
  }

  String _buildWeeklySuggestion({required Map<String, int> moodCounts}) {
    final stressed = (moodCounts['Stressed'] ?? 0) + (moodCounts['Tired'] ?? 0);
    final positive = (moodCounts['Calm'] ?? 0) + (moodCounts['Happy'] ?? 0);

    if (moodCounts.isEmpty) {
      return 'Try one mood check-in today—small logs add up to clearer weekly insights.';
    }
    if (stressed >= 3) {
      return 'You logged several stressed or tired days. Take a 3-minute breathing pause '
          'before you journal tonight, and note one small win from the day.';
    }
    if (positive >= 4) {
      return 'You had many calm or happy check-ins this week—great rhythm. '
          'Keep pairing mood logs with a short gratitude line in your journal.';
    }
    if (stressed > positive) {
      return 'Mood trend leans low-energy or stressed. A short walk or stretch before '
          'bed can make tomorrow’s check-in feel lighter.';
    }
    return 'Keep logging moods and journals—your next week’s summary will be sharper '
        'with steady check-ins.';
  }

  /// Published catalog (metadata). Optional fields per doc: title, description, type, linkUrl, sortOrder.
  Stream<QuerySnapshot> mindfulnessResourcesStream() {
    return _db.collection('mindfulnessResources').snapshots();
  }

  Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final ref = _db.collection('users').doc(uid);
    await ref.set({}, SetOptions(merge: true));

    final updates = <String, dynamic>{
      'profile.firstName': firstName.trim(),
      'profile.lastName': lastName.trim(),
      'profile.gender': (gender ?? '').trim(),
      'profile.updatedAt': FieldValue.serverTimestamp(),
    };

    if (dateOfBirth != null) {
      updates['profile.dateOfBirth'] = Timestamp.fromDate(
        DateTime(dateOfBirth.year, dateOfBirth.month, dateOfBirth.day),
      );
    }

    await ref.update(updates);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data == null) return null;
    final profile = data['profile'];
    if (profile is Map<String, dynamic>) return profile;
    if (profile is Map) {
      return Map<String, dynamic>.from(profile);
    }
    return null;
  }

  Future<ReminderSettingsData> getReminderSettings() async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc('settings')
        .get();

    if (!doc.exists) {
      return ReminderSettingsData(enabled: true, time24h: '20:00');
    }

    final d = doc.data() ?? {};
    return ReminderSettingsData(
      enabled: d['enabled'] as bool? ?? true,
      time24h: d['time']?.toString() ?? '20:00',
    );
  }

  Future<void> saveReminderSettings({
    required bool enabled,
    required String time24h,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('reminders')
        .doc('settings')
        .set({
      'enabled': enabled,
      'time': time24h,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFcmToken(String token) async {
    await _db.collection('users').doc(uid).set({
      'fcmToken': token,
      'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
