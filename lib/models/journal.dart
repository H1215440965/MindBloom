import 'package:cloud_firestore/cloud_firestore.dart';

class Journal {
  final String text;
  final List<String> moodTags;
  final DateTime date;

  Journal({required this.text, required this.moodTags, required this.date});

  Map<String, dynamic> toMap() => {'text': text, 'moodTags': moodTags, 'date': date};

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      text: map['text'],
      moodTags: List<String>.from(map['moodTags']),
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}