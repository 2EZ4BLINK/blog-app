import 'package:blog_forum/models/comment_image.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final List<CommentImage> images;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.images,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['post_id'],
      authorId: map['author_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
      images: (map['comment_images'] as List<dynamic>? ?? [])
          .map((image) => CommentImage.fromMap(image))
          .toList(),
    );
  }
}