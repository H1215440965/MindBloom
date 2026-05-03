import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/mindbloom_glass.dart';

/// Firestore collection: `mindfulnessResources`
/// Fields: `title` (string), `description` (string), `type` (optional string),
/// `linkUrl` (optional string), `sortOrder` (optional number).
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  static final List<_FallbackResource> _fallback = [
    _FallbackResource(
      title: '3-Minute Breathing Exercise',
      description:
          'Inhale for 4 counts, hold for 2, exhale for 6. Repeat for three minutes.',
      linkUrl: 'https://www.youtube.com/results?search_query=3+minute+breathing+exercise',
    ),
    _FallbackResource(
      title: 'Evening Reflection Guide',
      description:
          'Write one sentence: what felt heavy today, and one sentence: what felt light.',
    ),
    _FallbackResource(
      title: 'Gratitude Journal Prompt',
      description: 'List three small things you are grateful for—no repeats from yesterday.',
    ),
  ];

  int _sortOrder(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final v = doc.data()['sortOrder'];
    if (v is num) return v.toInt();
    return 999;
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.hasScheme)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid link')),
        );
      }
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MindBloomBackdrop(
      assetPath: 'images/background/resources.jpg',
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('mindfulnessResources')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: GreenGlassCard(
                  child: Text(
                    'Could not load resources.\n\n${snapshot.error}\n\n'
                    'Ensure you are signed in and Firestore rules allow '
                    'read on `mindfulnessResources`.',
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));

          final children = <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Mindfulness resources',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: GreenGlassCardColors.primaryOnCard(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                docs.isEmpty
                    ? 'No documents in `mindfulnessResources` yet—showing built-in suggestions. '
                        'Add docs in the Firebase Console (title, description, optional linkUrl, sortOrder).'
                    : 'Catalog from Firestore. Open a link to view external audio/video or guides.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: GreenGlassCardColors.tertiaryOnCard(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ];

          if (docs.isEmpty) {
            for (final r in _fallback) {
              children.add(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: GreenGlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color:
                                GreenGlassCardColors.primaryOnCard(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          r.description,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: GreenGlassCardColors.secondaryOnCard(
                                context),
                          ),
                        ),
                        if (r.linkUrl != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _openLink(context, r.linkUrl!),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Open link'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            for (final doc in docs) {
              final d = doc.data();
              final title = d['title']?.toString() ?? 'Resource';
              final body = d['description']?.toString() ?? '';
              final type = d['type']?.toString();
              final link = d['linkUrl']?.toString();

              children.add(
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: GreenGlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color:
                                GreenGlassCardColors.primaryOnCard(context),
                          ),
                        ),
                        if (type != null && type.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: GreenGlassCardColors.tertiaryOnCard(
                                  context),
                            ),
                          ),
                        ],
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            body,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: GreenGlassCardColors.secondaryOnCard(
                                  context),
                            ),
                          ),
                        ],
                        if (link != null && link.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _openLink(context, link),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Open link'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }
          }

          return ListView(children: children);
        },
      ),
    );
  }
}

class _FallbackResource {
  const _FallbackResource({
    required this.title,
    required this.description,
    this.linkUrl,
  });

  final String title;
  final String description;
  final String? linkUrl;
}
