import 'dart:io';

import 'package:blog_forum/models/profiles.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> updateProfile({
    required String name,
  }) async {
    final user = supabase.auth.currentUser!;

    await supabase
        .from('profiles')
        .update({'name': name})
        .eq('id', user.id);
  }

  Future<void> uploadAvatar(XFile image) async {
    final File imageFile = File(image.path);

    final user = supabase.auth.currentUser!;

    final String filePath =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('avatars')
        .upload(filePath, imageFile);

    final String avatarUrl = supabase.storage
        .from('avatars')
        .getPublicUrl(filePath);

    await supabase
        .from('profiles')
        .update({'avatar_url': avatarUrl})
        .eq('id', user.id);
  }

}