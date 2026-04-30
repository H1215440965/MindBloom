import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final fs = FirestoreService();
  final journalController = TextEditingController();

  void saveMood(String mood) {
    fs.addMood(mood);
  }

  void saveJournal() {
    fs.addJournal(journalController.text);
    journalController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MindBloom"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("How are you today?"),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () => saveMood("Happy"), child: Text("😊")),
                ElevatedButton(onPressed: () => saveMood("Calm"), child: Text("😌")),
                ElevatedButton(onPressed: () => saveMood("Stress"), child: Text("😫")),
              ],
            ),

            TextField(
              controller: journalController,
              decoration: InputDecoration(labelText: "Journal"),
            ),

            ElevatedButton(
              onPressed: saveJournal,
              child: Text("Save Journal"),
            )
          ],
        ),
      ),
    );
  }
}