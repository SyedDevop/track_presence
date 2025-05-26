import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/leave_model.dart';

class LeaveApi {
  late String baseUrl;
  Dio dio;
  LeaveApi({required this.dio});

  Future<List<Leave>> getLeaves(String userId) async {
    final res = await dio.get("leaves.php", queryParameters: {"id": userId});
    return LeaveReport.fromJson(res.data).data;
  }

  Future<void> postLeaves({
    required String userId,
    required String name,
    required String fromDate,
    required String toDate,
    required String reason,
    required String leaveType,
    required String department,
  }) async {
    await dio.post(
      "leaves.php",
      data: json.encode({
        "id": userId,
        "name": name,
        "from-date": fromDate,
        "to-date": toDate,
        "reason": reason,
        "department": department,
        "leave_type": leaveType,
      }),
      options: Options(contentType: "application/json"),
    );
  }

  Future<void> deleteLeaves({
    required String userId,
    required String leaveId,
  }) async {
    await dio.delete(
      "leaves.php",
      queryParameters: {"user_id": userId, "leave_id": leaveId},
    );
  }
}
