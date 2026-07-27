import 'package:blog_forum/models/post_image.dart';

class Post {
  final String id;
  final DateTime createdAt;
  final String authorId;
  final String title;
  final String content;
  final List<PostImage> images;

  Post({
    required this.id,
    required this.createdAt,
    required this.authorId,
    required this.title,
    required this.content,
    required this.images,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
        id: map['id'],
        createdAt: DateTime.parse(map['created_at']),
        authorId: map['author_id'],
        title: map['title'],
        content: map['content'], images: (map['post_images'] as List<dynamic>? ?? [])
          .map((image) => PostImage.fromMap(image))
          .toList()
    );
  }
}