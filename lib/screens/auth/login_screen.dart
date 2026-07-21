import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/shared/styled_button.dart';
import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = context.read<AuthProvider>();

    final isSuccess = await authProvider.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (isSuccess) {
      // Navigate to home later
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle("Blog App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const StyledTitle("Login"),

            // Email
            const SizedBox(height: 24),
            StyledTextField(
              controller: _emailController,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
            ),

            // Password
            const SizedBox(height: 16),
            StyledTextField(
              controller: _passwordController,
              label: "Password",
              obscureText: true,
            ),

            // Forgot Password
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const StyledText("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 24),
            StyledButton(
              onPressed: authProvider.isLoading ? null : _login,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login),
                  const SizedBox(width: 8),
                  StyledText(authProvider.isLoading ? "Logging In..." : "Login"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}