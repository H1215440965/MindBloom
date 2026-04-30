import 'package:cloud_firestore/cloud_firestore.dart';

class Mood {
  final String mood;
  final DateTime date;

  Mood({required this.mood, required this.date});

  Map<String, dynamic> toMap() => {'mood': mood, 'date': date};

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      mood: map['mood'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}