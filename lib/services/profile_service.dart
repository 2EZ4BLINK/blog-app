import 'package:blog_forum/models/profiles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Profile> fetchCurrentProfile() async {
    final user = supabase.auth.currentUser!;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile.fromMap(data);
  }
}