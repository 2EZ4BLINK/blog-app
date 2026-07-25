class Profile {
  final String id;
  final String name;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      avatarUrl: map['avatar_url'],
    );
  }
}