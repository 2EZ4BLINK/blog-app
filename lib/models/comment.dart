class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['post_id'],
      authorId: map['author_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}