import 'package:flutter/material.dart';

import '../widgets/mindbloom_glass.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MindBloomBackdrop(
      assetPath: 'images/background/insights.jpg',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GreenGlassCard(
            borderRadius: BorderRadius.circular(24),
            padding: const EdgeInsets.all(22),
            child: Text(
              'Weekly Insights\n\n'
              'You felt stressed on 3 of the last 7 days.\n\n'
              'Suggested Action:\n'
              'Try a short breathing break before journaling tonight.',
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
