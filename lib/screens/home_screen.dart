import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import 'journal_screen.dart';
import 'insights_screen.dart';
import 'resources_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeContent(),
    JournalScreen(),
    InsightsScreen(),
    ResourcesScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'MindBloom',
    'Journal',
    'Insights',
    'Resources',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: const Color(0xFFF7F3EC),
        foregroundColor: const Color(0xFF263128),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFFFFFBF5),
        indicatorColor: const Color(0xFFDDE8D9),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isSavingMood = false;
  String? _selectedMood;

  Future<void> _saveMood(String mood) async {
    setState(() {
      _isSavingMood = true;
      _selectedMood = mood;
    });

    try {
      await _firestoreService.saveMoodCheckIn(mood);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mood mood check-in saved.'),
          backgroundColor: const Color(0xFF6E8B74),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving mood: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingMood = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getUserName() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'User';

    if (email.contains('@')) {
      return email.split('@').first;
    }

    return email;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, ${_getUserName()}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263128),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Reflect, track, and grow today.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF6D716C),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.local_fire_department,
                  title: '7-day streak',
                  value: 'Keep going',
                  color: Color(0xFFE6A95C),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.check_circle_outline,
                  title: 'Mood check-ins',
                  value: 'Today',
                  color: Color(0xFF6E8B74),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
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
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263128),
                  ),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MoodButton(
                      label: 'Calm',
                      emoji: '🌿',
                      selected: _selectedMood == 'Calm',
                      disabled: _isSavingMood,
                      onTap: () => _saveMood('Calm'),
                    ),
                    _MoodButton(
                      label: 'Happy',
                      emoji: '😊',
                      selected: _selectedMood == 'Happy',
                      disabled: _isSavingMood,
                      onTap: () => _saveMood('Happy'),
                    ),
                    _MoodButton(
                      label: 'Stressed',
                      emoji: '😣',
                      selected: _selectedMood == 'Stressed',
                      disabled: _isSavingMood,
                      onTap: () => _saveMood('Stressed'),
                    ),
                    _MoodButton(
                      label: 'Tired',
                      emoji: '😴',
                      selected: _selectedMood == 'Tired',
                      disabled: _isSavingMood,
                      onTap: () => _saveMood('Tired'),
                    ),
                  ],
                ),

                if (_isSavingMood) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JournalScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note),
              label: const Text('Start Journal Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E8B74),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1E7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF6E8B74),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Today's reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263128),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Take a 3-minute pause and write one thing you are grateful for.',
                  style: TextStyle(
                    color: Color(0xFF4E5A50),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  const _MoodButton({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor =
        selected ? const Color(0xFF6E8B74) : const Color(0xFFF2EDE3);
    final Color textColor =
        selected ? Colors.white : const Color(0xFF263128);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6D716C),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF263128),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}