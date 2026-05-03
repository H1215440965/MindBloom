import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Weekly Insights\n\n'
          'You felt stressed on 3 of the last 7 days.\n\n'
          'Suggested Action:\n'
          'Try a short breathing break before journaling tonight.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}