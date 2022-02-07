import 'package:uuid/uuid.dart';

class BackgroundTaskModel {
  late final String uuid;
  final String platform;
  final String taskName;
  final DateTime? executionDateTime;

  BackgroundTaskModel(
      {String? uuid,
      required this.platform,
      required this.taskName,
      this.executionDateTime}) {
    this.uuid = uuid ?? const Uuid().v1();
  }

  factory BackgroundTaskModel.fromJson(Map<String, dynamic> json) =>
      BackgroundTaskModel(
        uuid: json['uuid'],
        taskName: json['task_name'],
        platform: json['platform'],
        executionDateTime: json['execution_date_time'] != null
            ? DateTime.tryParse(json['execution_date_time'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'task_name': taskName,
        'platform': platform,
        'execution_date_time': executionDateTime?.toIso8601String()
      };

  @override
  String toString() {
    return '$uuid, $platform, $taskName, $executionDateTime';
  }
}
