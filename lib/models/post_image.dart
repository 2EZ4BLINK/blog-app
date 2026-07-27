class PostImage {
  final String id;
  final String postId;
  final String imageUrl;
  final DateTime createdAt;

  PostImage({
    required this.id,
    required this.postId,
    required this.imageUrl,
    required this.createdAt,
  });

  factory PostImage.fromMap(Map<String, dynamic> map) {
    return PostImage(
      id: map['id'],
      postId: map['post_id'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}