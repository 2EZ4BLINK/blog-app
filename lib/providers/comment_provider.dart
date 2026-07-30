import 'package:blog_forum/models/comment.dart';
import 'package:blog_forum/models/comment_image.dart';
import 'package:blog_forum/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommentProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Comment> _comments = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Comment> get comments => _comments;

  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
       _comments = await _postService.fetchComments(postId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createComment({
    required String postId,
    required String content,
    required List<XFile> images,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final commentId = await _postService.createComment(
        postId: postId,
        content: content,
      );
      for (final image in images) {
        await _postService.uploadCommentImage(
          commentId: commentId,
          image: image,
        );
      }
      await fetchComments(postId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
    required List<CommentImage> originalImages,
    required List<CommentImage> existingImages,
    required List<XFile> newImages,
  }) async
  {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.updateComment(
        commentId: commentId,
        content: content,
      );

      final removedImages = originalImages.where((image) {
        return !existingImages.any(
              (existingImage) => existingImage.id == image.id,
        );
      }).toList();

      for (final image in removedImages) {
        await _postService.deleteCommentImage(
          imageId: image.id,
        );
      }

      for (final image in newImages) {
        await _postService.uploadCommentImage(
          commentId: commentId,
          image: image,
        );
      }
      await fetchComments(postId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async
  {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.deleteComment(commentId);
      await fetchComments(postId);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}