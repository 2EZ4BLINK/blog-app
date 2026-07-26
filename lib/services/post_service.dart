import 'package:blog_forum/config/supabase_config.dart';
import 'package:blog_forum/models/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<void> createPost({
    required String title,
    required String content,
  }) async {
    final user = supabase.auth.currentUser!;

   await supabase
       .from('posts')
       .insert({'author_id': user.id, 'title': title, 'content': content});
  }

  Future<List<Post>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    List<Post> posts = response.map((json) => Post.fromJson(json)).toList();

    return posts;
  }

  Future<void> deletePost(postId) async {
    await supabase
        .from('posts')
        .delete()
        .eq('id', postId);
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async {
    await supabase
        .from('posts')
        .update({
          'title': title,
          'content': content,
        })
        .eq('id', postId);
  }
}