import 'dart:io';

import 'package:blog_forum/models/post.dart';
import 'package:blog_forum/models/post_image.dart';
import 'package:blog_forum/services/post_service.dart';
import 'package:flutter/material.dart';

class PostProvider extends ChangeNotifier{
  final PostService _postService = PostService();

  int _page = 0;
  String? _errorMessage;

  final int _limit = 5;
  final List<Post> _posts = [];

  bool _hasMore = true;
  bool _isLoading = false;

  bool get hasMore => _hasMore;
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
      await fetchPosts(refresh: true);
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

  Future<void> fetchPosts({
    bool refresh = false,
  }) async
  {
    if (refresh) {
      _page = 0;
      _posts.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final posts = await _postService.fetchPosts(
        page: _page,
        limit: _limit,
      );

      _posts.addAll(posts);
      if (posts.length < _limit) {
        _hasMore = false;
      }
      _page++;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePost(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      await _postService.deletePost(postId);
      await fetchPosts(refresh: true);
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
    required List<PostImage> originalImages,
    required List<PostImage> existingImages,
    required List<File> newImages,
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

      final removedImages = originalImages.where((image) {
        return !existingImages.any(
              (existingImage) => existingImage.id == image.id,
        );
      }).toList();

      for (final image in removedImages) {
        await _postService.deletePostImage(
          imageId: image.id,
        );
      }

      for (final image in newImages) {
        await _postService.uploadPostImage(
          postId: postId,
          image: image,
        );
      }

      await fetchPosts(refresh: true);
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
  }) async
  {
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
      await fetchPosts(refresh: true);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}