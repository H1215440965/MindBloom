import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../widgets/mindbloom_glass.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  late Future<WeeklyInsightsResult> _future;

  @override
  void initState() {
    super.initState();
    _future = FirestoreService().getWeeklyInsights();
  }

  Future<void> _reload() async {
    setState(() {
      _future = FirestoreService().getWeeklyInsights();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return MindBloomBackdrop(
      assetPath: 'images/background/insights.jpg',
      child: RefreshIndicator(
        onRefresh: _reload,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: FutureBuilder<WeeklyInsightsResult>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 120),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: GreenGlassCard(
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.all(22),
                          child: Text(
                            'Could not load insights.\n\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: GreenGlassCardColors.primaryOnCard(context),
                              height: 1.45,
                            ),
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data!;
                    return Center(
                      child: GreenGlassCard(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly insights',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: GreenGlassCardColors.primaryOnCard(context),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Based on your last 7 days of Firestore mood check-ins '
                              'and completed journal entries.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: GreenGlassCardColors.tertiaryOnCard(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              data.summary,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.55,
                                color: GreenGlassCardColors.secondaryOnCard(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Suggestion',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: GreenGlassCardColors.primaryOnCard(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.suggestion,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.55,
                                color: GreenGlassCardColors.secondaryOnCard(context),
                              ),
                            ),
                            if (data.moodCounts.isNotEmpty) ...[
                              const SizedBox(height: 18),
                              Text(
                                'Mood breakdown',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: GreenGlassCardColors.primaryOnCard(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...data.moodCounts.entries.map((e) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${e.key}: ${e.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: GreenGlassCardColors.tertiaryOnCard(
                                          context),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
