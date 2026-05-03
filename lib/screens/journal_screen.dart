import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/firestore_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _journalController = TextEditingController();

  String _selectedMood = 'Calm';
  bool _isSaving = false;

  final List<String> _availableTags = [
    'anxious',
    'hopeful',
    'tired',
    'grateful',
    'stressed',
    'calm',
  ];

  final List<String> _selectedTags = [];

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _saveJournal({required bool isDraft}) async {
    final content = _journalController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestoreService.saveJournalEntry(
        content: content,
        mood: _selectedMood,
        tags: _selectedTags,
        isDraft: isDraft,
      );

      _journalController.clear();

      setState(() {
        _selectedMood = 'Calm';
        _selectedTags.clear();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDraft ? 'Draft saved.' : 'Journal entry saved.'),
          backgroundColor: const Color(0xFF6E8B74),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving journal: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteEntry(String docId) async {
    try {
      await _firestoreService.deleteJournalEntry(docId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Journal entry deleted.'),
          backgroundColor: Color(0xFF6E8B74),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) {
      return 'Just now';
    }

    if (timestamp is Timestamp) {
      return DateFormat('MMM d, yyyy • h:mm a').format(timestamp.toDate());
    }

    return 'Unknown date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJournalInputCard(),
            const SizedBox(height: 24),
            const Text(
              'Your Journal History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263128),
              ),
            ),
            const SizedBox(height: 12),
            _buildJournalHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Journal Entry',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263128),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Mood',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF263128),
            ),
          ),
          const SizedBox(height: 8),

          DropdownButtonFormField<String>(
            value: _selectedMood,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF2EDE3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Calm', child: Text('Calm')),
              DropdownMenuItem(value: 'Happy', child: Text('Happy')),
              DropdownMenuItem(value: 'Stressed', child: Text('Stressed')),
              DropdownMenuItem(value: 'Tired', child: Text('Tired')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedMood = value;
              });
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Mood Tags',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF263128),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);

              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                selectedColor: const Color(0xFF6E8B74),
                backgroundColor: const Color(0xFFF2EDE3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF263128),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => _toggleTag(tag),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _journalController,
            minLines: 7,
            maxLines: 12,
            decoration: InputDecoration(
              hintText:
                  'Today I felt a little overwhelmed, but writing things down helped me slow down...',
              filled: true,
              fillColor: const Color(0xFFF2EDE3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 18),

          if (_isSaving) const LinearProgressIndicator(),

          if (_isSaving) const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          _saveJournal(isDraft: true);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6E8B74),
                    side: const BorderSide(
                      color: Color(0xFF6E8B74),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          _saveJournal(isDraft: false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E8B74),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getJournalEntries(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'Could not load journal entries.',
            style: TextStyle(color: Colors.redAccent),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'No journal entries yet. Write your first reflection above.',
              style: TextStyle(
                color: Color(0xFF6D716C),
                height: 1.4,
              ),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final content = data['content'] ?? '';
            final mood = data['mood'] ?? 'Unknown';
            final tags = data['tags'] ?? [];
            final isDraft = data['isDraft'] ?? false;
            final createdAt = data['createdAt'];

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1E7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          mood.toString(),
                          style: const TextStyle(
                            color: Color(0xFF6E8B74),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isDraft == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE7C2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Draft',
                            style: TextStyle(
                              color: Color(0xFF9A6A24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          _deleteEntry(doc.id);
                        },
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _formatDate(createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6D716C),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    content.toString(),
                    style: const TextStyle(
                      color: Color(0xFF263128),
                      height: 1.45,
                      fontSize: 15,
                    ),
                  ),

                  if (tags is List && tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.map<Widget>((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EDE3),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6D716C),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}