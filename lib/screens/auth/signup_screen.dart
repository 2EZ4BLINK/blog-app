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
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _handleSignup() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim()
    );

    if (!mounted) return;

    if(authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Failed creating account'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          showCloseIcon: true,
          duration: Duration(seconds: 3),
          content: StyledText('Account successfully created'),
        ),
      );
    }

    if (success) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StyledTextField(
              controller: nameController,
              label: 'Name',
            ),
            const SizedBox(height: 16),
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
              onPressed: authProvider.isLoading ? null : _handleSignup,
              child: authProvider.isLoading
                  ? const StyledText('Creating...')
                  : const StyledText('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}