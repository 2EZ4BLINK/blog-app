class CommentImage {
  final String id;
  final String commentId;
  final String imageUrl;
  final DateTime createdAt;

  CommentImage({
    required this.id,
    required this.commentId,
    required this.imageUrl,
    required this.createdAt,
  });

  factory CommentImage.fromMap(Map<String, dynamic> map) {
    return CommentImage(
      id: map['id'],
      commentId: map['comment_id'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}