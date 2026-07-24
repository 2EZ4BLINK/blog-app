import 'package:blog_forum/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Failed to create user.');
    }

    await supabase
        .from('profiles')
        .insert({ 'id': user.id, 'name': name})
        .select();
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