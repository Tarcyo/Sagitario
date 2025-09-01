class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? type;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.type,
    required this.createdAt,
    required this.updatedAt,
  });
}
