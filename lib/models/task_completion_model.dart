import 'dart:io';

class TaskCompletion {
  final int taskId;
  final String? locationName;
  final String? summary;
  final String? comments;
  final List<File>? photos;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? customFields;

  TaskCompletion({
    required this.taskId,
    this.locationName,
    this.summary,
    this.comments,
    this.photos,
    this.latitude,
    this.longitude,
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'location_name': locationName,
      'summary': summary,
      'comments': comments,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'custom_fields': customFields,
    };
  }
}

class TaskCompletionResponse {
  final int status;
  final String? message;
  final bool success;

  TaskCompletionResponse({
    required this.status,
    this.message,
    required this.success,
  });

  factory TaskCompletionResponse.fromJson(Map<String, dynamic> json) {
    return TaskCompletionResponse(
      status: json['status'] ?? 0,
      message: json['message'],
      success: json['status'] == 200,
    );
  }
}
