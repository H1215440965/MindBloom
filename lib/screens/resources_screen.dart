import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Mindfulness Resources\n\n'
          '• 3-Minute Breathing Exercise\n'
          '• Evening Reflection Guide\n'
          '• Gratitude Journal Prompt\n\n'
          'Prototype version uses Firestore metadata instead of Firebase Storage.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}