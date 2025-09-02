import 'package:sagitario/layers/domain/entities/scheduleEntity.dart';


class ScheduleModel extends Schedule {
  ScheduleModel({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) : super(dayOfWeek: dayOfWeek, startTime: startTime, endTime: endTime);

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      };
}
