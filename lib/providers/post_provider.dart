import 'dart:io';

import 'package:blog_forum/config/supabase_config.dart';
import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/services/post_service.dart';
import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier{
  final PostService _postService = PostService();

  final List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<String?> createPost({
    required String title,
    required String content,
  }) async
  {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final postId = await _postService.createPost(
        title: title,
        content: content,
      );
      await fetchPosts();
      return postId;
    }
    catch(error){
      _errorMessage = error.toString();
      return null;
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final posts = await _postService.fetchPosts();
      _posts.clear();
      _posts.addAll(posts);
    }
    catch(error)
    {
      _errorMessage = error.toString();
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      await _postService.deletePost(postId);
      await fetchPosts();
    }
    catch(error)
    {
      _errorMessage = error.toString();
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
  }) async
  {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.updatePost(
        postId: postId,
        title: title,
        content: content,
      );
      await fetchPosts();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPostImages({
    required String postId,
    required List<File> images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final image in images) {
        await _postService.uploadPostImage(
          postId: postId,
          image: image,
        );
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    await fetchPosts();
  }
}