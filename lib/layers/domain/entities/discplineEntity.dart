import 'classroom.dart';
import 'user.dart';
import 'schedule.dart';

class Discipline {
  final String id;
  final String name;
  final String? description;
  final int totalClasses;
  final Classroom classroom;
  final User teacher;
  final List<User> students;
  final List<Schedule> schedule;
  final DateTime createdAt;
  final DateTime updatedAt;

  Discipline({
    required this.id,
    required this.name,
    this.description,
    required this.totalClasses,
    required this.classroom,
    required this.teacher,
    required this.students,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
  });
}
