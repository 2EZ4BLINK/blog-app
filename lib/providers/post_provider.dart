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
}