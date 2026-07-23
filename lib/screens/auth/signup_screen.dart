import 'package:blog_forum/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../shared/styled_button.dart';
import '../../shared/styled_text.dart';
import '../../shared/styled_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void handleSignup() async {
    final success = await context.read<AuthProvider>().signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim()
    );

    if (!mounted) return;

    if (success) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyledTextField(
              controller: emailController,
              label: 'Email',
            ),
            const SizedBox(height: 16),
            StyledTextField(
              controller: passwordController,
              label: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            StyledButton(
              onPressed: handleSignup,
              child: const StyledText('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}