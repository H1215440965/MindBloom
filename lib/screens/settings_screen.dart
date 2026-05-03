import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/firestore_service.dart';
import '../theme/theme_controller.dart';
import '../widgets/mindbloom_glass.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestore = FirestoreService();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();

  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _reminderSyncing = false;
  bool _profileLoading = true;
  bool _profileSaving = false;

  DateTime? _dateOfBirth;
  String? _gender;

  static const _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final r = await _firestore.getReminderSettings();
      if (!mounted) return;
      setState(() {
        _reminderEnabled = r.enabled;
        _reminderTime = _parseTime24h(r.time24h);
      });
    } catch (_) {
      // Keep defaults
    }
  }

  TimeOfDay _parseTime24h(String raw) {
    final parts = raw.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _reminderTimeToFirestore() {
    final t = _reminderTime;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _persistReminderSettings() async {
    setState(() => _reminderSyncing = true);
    try {
      await _firestore.saveReminderSettings(
        enabled: _reminderEnabled,
        time24h: _reminderTimeToFirestore(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save reminder: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reminderSyncing = false);
    }
  }

  Future<void> _pickReminderTime() async {
    if (_reminderSyncing) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked == null || !mounted) return;
    setState(() => _reminderTime = picked);
    await _persistReminderSettings();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _profileLoading = true);
    try {
      final profile = await _firestore.getUserProfile();
      if (!mounted) return;
      if (profile != null) {
        _firstName.text = profile['firstName']?.toString() ?? '';
        _lastName.text = profile['lastName']?.toString() ?? '';
        final rawDob = profile['dateOfBirth'];
        if (rawDob is Timestamp) {
          _dateOfBirth = rawDob.toDate();
        }
        final g = profile['gender']?.toString();
        _gender = (g != null && g.isNotEmpty) ? g : null;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load profile.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _profileLoading = false);
    }
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 18, 6, 15);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _profileSaving = true);
    try {
      await _firestore.saveUserProfile(
        firstName: _firstName.text,
        lastName: _lastName.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved.'),
          backgroundColor: Color(0xFF6E8B74),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _profileSaving = false);
    }
  }

  String _dobLabel() {
    if (_dateOfBirth == null) return 'Tap to choose date of birth';
    return DateFormat.yMMMd().format(_dateOfBirth!);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final themeController = context.watch<ThemeController>();

    InputDecoration fieldDecoration(String label) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        labelStyle: TextStyle(
          color: GreenGlassCardColors.secondaryOnCard(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.45)),
        ),
      );
    }

    return MindBloomBackdrop(
      assetPath: 'images/background/settings.jpg',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          GreenGlassCard(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Profile',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: GreenGlassCardColors.primaryOnCard(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_profileLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  TextField(
                    controller: _firstName,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                    decoration: fieldDecoration('First name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lastName,
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                    decoration: fieldDecoration('Last name'),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: _profileSaving ? null : _pickDateOfBirth,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cake_outlined,
                              color: scheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of birth',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: GreenGlassCardColors
                                          .tertiaryOnCard(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _dobLabel(),
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: GreenGlassCardColors
                                          .primaryOnCard(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: GreenGlassCardColors.tertiaryOnCard(
                                  context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue:
                        _gender != null && _genderOptions.contains(_gender)
                            ? _gender
                            : null,
                    dropdownColor: scheme.surfaceContainerHigh,
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                    decoration: fieldDecoration('Gender'),
                    hint: Text(
                      'Select gender',
                      style: TextStyle(
                        color: GreenGlassCardColors.tertiaryOnCard(context),
                      ),
                    ),
                    items: _genderOptions
                        .map(
                          (g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ),
                        )
                        .toList(),
                    onChanged: _profileSaving
                        ? null
                        : (value) {
                            setState(() => _gender = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _profileSaving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _profileSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save profile'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GreenGlassCard(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Appearance',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: GreenGlassCardColors.primaryOnCard(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Theme',
                  style: textTheme.labelLarge?.copyWith(
                    color: GreenGlassCardColors.tertiaryOnCard(context),
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined, size: 18),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined, size: 18),
                    ),
                  ],
                  selected: {themeController.themeMode},
                  onSelectionChanged: (selection) {
                    if (selection.isEmpty) return;
                    themeController.setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GreenGlassCard(
            borderRadius: BorderRadius.circular(22),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Daily Journal Reminder',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                  ),
                  subtitle: Text(
                    _reminderSyncing
                        ? 'Saving…'
                        : 'Prompt at ${_reminderTime.format(context)}. '
                            'FCM delivery still needs a server scheduler (e.g. Cloud Functions).',
                    style: textTheme.bodySmall?.copyWith(
                      color: GreenGlassCardColors.secondaryOnCard(context),
                      height: 1.35,
                    ),
                  ),
                  value: _reminderEnabled,
                  activeThumbColor: scheme.primary,
                  onChanged: _reminderSyncing
                      ? null
                      : (value) async {
                          setState(() => _reminderEnabled = value);
                          await _persistReminderSettings();
                        },
                ),
                ListTile(
                  enabled: !_reminderSyncing,
                  leading: Icon(Icons.schedule, color: scheme.primary),
                  title: Text(
                    'Reminder time',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                  ),
                  subtitle: Text(
                    _reminderTime.format(context),
                    style: textTheme.bodySmall?.copyWith(
                      color: GreenGlassCardColors.secondaryOnCard(context),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickReminderTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GreenGlassCard(
            borderRadius: BorderRadius.circular(22),
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: scheme.primary,
              ),
              title: Text(
                'Privacy',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: GreenGlassCardColors.primaryOnCard(context),
                ),
              ),
              subtitle: Text(
                'Your journal and mood data are stored privately under your Firebase user ID.',
                style: textTheme.bodySmall?.copyWith(
                  color: GreenGlassCardColors.secondaryOnCard(context),
                  height: 1.35,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
