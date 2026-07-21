import 'package:blog_forum/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() {
    return supabase.auth.signOut();
  }
}