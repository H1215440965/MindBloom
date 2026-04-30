import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();

  bool isLogin = true;
  String error = "";

  void submit() async {
    try {
      if (isLogin) {
        await auth.login(email.text.trim(), password.text.trim());
      } else {
        await auth.register(email.text.trim(), password.text.trim());
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isLogin ? "Login" : "Register",
                style: TextStyle(fontSize: 28)),

            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: password,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: Text(isLogin ? "Login" : "Register"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                  error = "";
                });
              },
              child: Text(isLogin
                  ? "Create account"
                  : "Already have account? Login"),
            ),

            if (error.isNotEmpty)
              Text(error, style: TextStyle(color: Colors.red))
          ],
        ),
      ),
    );
  }
}