class User {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? location;
  final String? joinedAt;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.location,
    this.joinedAt,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] as String?,
      location: json['location'] as String?,
      joinedAt: json['joined_at'] as String? ?? json['joinedAt'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
    );
  }
}
