

import 'package:sagitario/layers/domain/entities/classromEntity.dart';
import 'package:sagitario/layers/domain/entities/discplineEntity.dart';
import 'package:sagitario/layers/domain/entities/scheduleModel.dart';
import 'package:sagitario/layers/domain/entities/userModel.dart';

class DisciplineModel extends Discipline {
  DisciplineModel({
    required String id,
    required String name,
    String? description,
    required int totalClasses,
    required Classroom classroom,
    required UserModel teacher,
    required List<UserModel> students,
    required List<ScheduleModel> schedule,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          totalClasses: totalClasses,
          classroom: classroom,
          teacher: teacher,
          students: students,
          schedule: schedule,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory DisciplineModel.fromJson(Map<String, dynamic> json) {
    return DisciplineModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalClasses: (json['total_classes'] ?? 0) as int,
      classroom: ClassroomModel.fromJson(json['classroom'] as Map<String, dynamic>),
      teacher: UserModel.fromJson(json['teacher'] as Map<String, dynamic>),
      students: (json['students'] as List<dynamic>?)
              ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'total_classes': totalClasses,
      'classroom': (classroom as ClassroomModel).toJson(),
      'teacher': (teacher as UserModel).toJson(),
      'students': students.map((s) => (s as UserModel).toJson()).toList(),
      'schedule': schedule.map((s) => (s as ScheduleModel).toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ClassroomModel extends Classroom {
  ClassroomModel({
    required String id,
    required String name,
    required String latitude,
    required String longitude,
    required int minDistance,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          latitude: latitude,
          longitude: longitude,
          minDistance: minDistance,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      minDistance: (json['min_distance'] ?? 0) as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'min_distance': minDistance,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
