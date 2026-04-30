import 'package:flutter/material.dart';

class MoodButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  MoodButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}