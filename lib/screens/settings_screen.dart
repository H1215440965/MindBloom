import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () async {
                await _auth.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          title: Text("About MindBloom"),
                          content: Text("MindBloom v1.0 - Mood and Journal Tracker"),
                        ));
              },
            ),
          ],
        ),
      ),
    );
  }
}