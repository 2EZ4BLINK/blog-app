import 'package:blog_forum/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:blog_forum/shared/styled_text.dart';
import 'package:blog_forum/shared/styled_button.dart';
import 'package:blog_forum/providers/auth_provider.dart';
import 'package:blog_forum/shared/styled_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isEmailEmpty = false;
  bool isPasswordEmpty = false;
  bool isEmailInvalid = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    setState(() {
      isEmailEmpty = email.isEmpty;
      isPasswordEmpty = password.isEmpty;
      isEmailInvalid = email.isNotEmpty && !emailRegex.hasMatch(email);
    });

    final hasValidationError =
        isEmailEmpty || isPasswordEmpty || isEmailInvalid;

    if (hasValidationError) return;

    final authProvider = context.read<AuthProvider>();

    final isSuccess = await authProvider.signIn(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (isSuccess) {
      context.go('/');
    }
  }

  void _clearEmailError() {
    final authProvider = context.read<AuthProvider>();
    if (isEmailEmpty || isEmailInvalid) {
      setState(() {
        isEmailEmpty = false;
        isEmailInvalid = false;
      });
    }
    authProvider.clearError();
  }

  void _clearPasswordError() {
    final authProvider =  context.read<AuthProvider>();
    if (isPasswordEmpty) {
      setState(() {
        isPasswordEmpty = false;
      });
    }
    authProvider.clearError();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            const SizedBox(height: 24),
            StyledTextField(
              label: "Email",
              controller: _emailController,
              onChanged: (_) => _clearEmailError(),
              keyboardType: TextInputType.emailAddress,
            ),

            if (isEmailEmpty) ...[
              const SizedBox(height: 8),
              const StyledTextError("Email should not be empty"),
            ],

            if (isEmailInvalid) ...[
              const SizedBox(height: 8),
              const StyledTextError("Please enter a valid email address"),
            ],

            const SizedBox(height: 16),

            StyledTextField(
              controller: _passwordController,
              label: "Password",
              obscureText: true,
              onChanged: (_) => _clearPasswordError(),
            ),

            if (isPasswordEmpty) ...[
              const SizedBox(height: 8),
              const StyledTextError("Password should not be empty"),
            ],

            if (authProvider.errorMessage != null) ...[
              const SizedBox(height: 8),
              StyledTextError('Invalid login credentials'),
            ],

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => context.go('/signup'),
                style: TextButton.styleFrom(overlayColor: AppColors.textColor),
                child: const StyledText("Create an account"),
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
                  StyledText(
                    authProvider.isLoading
                        ? "Logging In..."
                        : "Login",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}