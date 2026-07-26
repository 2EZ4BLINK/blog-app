class Post {
  final String id;
  final DateTime createdAt;
  final String authorId;
  final String title;
  final String content;

  Post({
    required this.id,
    required this.createdAt,
    required this.authorId,
    required this.title,
    required this.content,
  });

  Post.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        createdAt = DateTime.parse(json['created_at']),
        authorId = json['author_id'],
        title = json['title'],
        content = json['content'];

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      authorId: map['author_id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

}