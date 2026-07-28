import 'dart:io';

import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/post.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostService {
  final supabase = Supabase.instance.client;

  Future<String> createPost({
    required String title,
    required String content,
  }) async
  {
    final user = supabase.auth.currentUser!;

    final response = await supabase
        .from('posts')
        .insert({
          'author_id': user.id,
          'title': title,
          'content': content,
        })
        .select()
        .single();

    return response['id'];
  }

  Future<List<Post>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select('''
          *,
          post_images(*)
        ''')
        .order('created_at', ascending: false);

    List<Post> posts = response
        .map((json) => Post.fromMap(json))
        .toList();

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
  }) async
  {
    await supabase
        .from('posts')
        .update({
          'title': title,
          'content': content,
        })
        .eq('id', postId);
  }

  Future<void> uploadPostImage({
    required String postId,
    required File image,
  }) async
  {
    final user = supabase.auth.currentUser!;

    final filePath =
        '${user.id}/$postId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('post-images')
        .upload(filePath, image);

    final imageUrl = supabase.storage
        .from('post-images')
        .getPublicUrl(filePath);

    await supabase.from('post_images').insert({
      'post_id': postId,
      'image_url': imageUrl,
    });
  }

  Future<List<Comment>> fetchComments(String postId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: false);

    final comments = response
        .map((json) => Comment.fromMap(json))
        .toList();

    return comments;
  }

  Future<void> createComment({
    required String postId,
    required String content,
  }) async {
    final user = supabase.auth.currentUser!;

    await supabase.from('comments').insert({
      'post_id': postId,
      'author_id': user.id,
      'content': content,
    });
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    await supabase
        .from('comments')
        .update({'content': content})
        .eq('id', commentId);
  }

  Future<void> deleteComment(String commentId) async {
    await supabase
        .from('comments')
        .delete()
        .eq('id', commentId);
  }
}