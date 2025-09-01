class Classroom {
  final String id;
  final String name;
  final String latitude;
  final String longitude;
  final int minDistance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.minDistance,
    required this.createdAt,
    required this.updatedAt,
  });
}
