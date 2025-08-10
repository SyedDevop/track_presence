import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/task_completion_model.dart';
import 'package:vcare_attendance/models/task_model.dart';

class TaskApi {
  final Dio dio;

  const TaskApi({required this.dio});

  /// Get list of tasks with optional filters
  Future<TaskResponse> getTasks({
    bool showAll = false,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'all': showAll.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await dio.get(
        'task.php',
        queryParameters: queryParams,
      );

      return TaskResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get single task by ID
  Future<Task?> getTask(int taskId, {bool showAll = false}) async {
    try {
      final response = await dio.get(
        'task.php',
        queryParameters: {
          'task_id': taskId.toString(),
          'all': showAll.toString(),
        },
      );
      final data = response.data["data"];
      return Task.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete a task with submission data
  Future<TaskCompletionResponse> completeTask({
    required int taskId,
    required String name, // NOW REQUIRED
    required String summary, // NOW REQUIRED
    required String observation, // NOW REQUIRED
    required File photos,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      FormData formData = FormData();

      // Add required fields
      formData.fields.add(MapEntry('task_id', taskId.toString()));
      formData.fields.add(MapEntry('action', 'complete'));
      formData.fields.add(MapEntry('name', name));
      formData.fields.add(MapEntry('summary', summary));
      formData.fields.add(MapEntry('observation', observation));

      if (latitude != null) {
        formData.fields.add(MapEntry('latitude', latitude.toString()));
      }
      if (longitude != null) {
        formData.fields.add(MapEntry('longitude', longitude.toString()));
      }

      // Add custom fields
      if (customFields != null) {
        for (var entry in customFields.entries) {
          formData.fields
              .add(MapEntry('custom_${entry.key}', entry.value.toString()));
        }
      }

      // Add photo
      String fileName = photos.path.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();
      String contentType;
      switch (fileExtension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        default:
          contentType = 'image/jpeg'; // Default fallback
      }
      formData.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(
            photos.path,
            filename: fileName,
            contentType: DioMediaType.parse(contentType),
          ),
        ),
      );

      final response = await dio.post(
        'task.php',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return TaskCompletionResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// /// Update task status (if you need this functionality)
  /// Future<TaskResponse> updateTaskStatus(int taskId, String status) async {
  ///   try {
  ///     final response = await dio.put(
  ///       'task.php',
  ///       data: json.encode({
  ///         'task_id': taskId,
  ///         'status': status,
  ///       }),
  ///       options: Options(contentType: "application/json"),
  ///     );
  ///
  ///     return TaskResponse.fromJson(response.data);
  ///   } catch (e) {
  ///     rethrow;
  ///   }
  /// }
  ///
  /// /// Create new task (if you need this functionality)
  /// Future<TaskResponse> createTask({
  ///   required String assignedTo,
  ///   String? assignedName,
  ///   required String title,
  ///   String? description,
  ///   DateTime? targetDate,
  ///   double? latitude,
  ///   double? longitude,
  /// }) async {
  ///   try {
  ///     final response = await dio.post(
  ///       'task.php',
  ///       data: json.encode({
  ///         'assigned_to': assignedTo,
  ///         'assigned_name': assignedName,
  ///         'title': title,
  ///         'description': description,
  ///         'target_date': targetDate?.toIso8601String(),
  ///         'latitude': latitude?.toString(),
  ///         'longitude': longitude?.toString(),
  ///       }),
  ///       options: Options(contentType: "application/json"),
  ///     );
  ///
  ///     return TaskResponse.fromJson(response.data);
  ///   } catch (e) {
  ///     rethrow;
  ///   }
  /// }
}
