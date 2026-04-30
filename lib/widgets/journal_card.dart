import 'package:flutter/material.dart';
import '../models/journal.dart';

class JournalCard extends StatelessWidget {
  final Journal journal;
  JournalCard({required this.journal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(journal.text),
        subtitle: Text(journal.moodTags.join(", ")),
        trailing: Text("${journal.date.month}/${journal.date.day}"),
      ),
    );
  }
}