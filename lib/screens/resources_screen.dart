import 'package:flutter/material.dart';

import '../widgets/mindbloom_glass.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindBloomBackdrop(
      assetPath: 'images/background/resources.jpg',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GreenGlassCard(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(22),
            child: Text(
              'Mindfulness Resources\n\n'
              '• 3-Minute Breathing Exercise\n'
              '• Evening Reflection Guide\n'
              '• Gratitude Journal Prompt\n\n'
              'Prototype version uses Firestore metadata instead of Firebase Storage.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.55,
                color: GreenGlassCardColors.primaryOnCard(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
