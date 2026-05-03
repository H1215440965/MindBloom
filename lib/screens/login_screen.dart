import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/mindbloom_glass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();

  bool isLogin = true;
  String error = "";

  InputDecoration _fieldDecoration(BuildContext context, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.88),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color(0xFF6E8B74).withValues(alpha: isDark ? 0.45 : 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: const Color(0xFF6E8B74).withValues(alpha: isDark ? 0.38 : 0.28),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF6E8B74),
          width: 1.5,
        ),
      ),
      labelStyle: TextStyle(
        color: GreenGlassCardColors.secondaryOnCard(context),
        fontWeight: FontWeight.w500,
      ),
    );
  }

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
      body: MindBloomBackdrop(
        assetPath: 'images/background/loginscreen.jpg',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GreenGlassCard(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "Welcome, Login!" : "Welcome, Register!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: email,
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                    decoration: _fieldDecoration(context, "Email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    style: TextStyle(
                      color: GreenGlassCardColors.primaryOnCard(context),
                    ),
                    decoration: _fieldDecoration(context, "Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(46),
                    ),
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
                    child: Text(
                      isLogin
                          ? "Create account"
                          : "Already have account? Login",
                      style: TextStyle(
                        color: GreenGlassCardColors.secondaryOnCard(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (error.isNotEmpty)
                    Text(error, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
