import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:vcare_attendance/api/error.dart';

import 'package:vcare_attendance/models/leave_model.dart';

class LeaveApi {
  late String baseUrl;
  late String url;
  Dio dio;
  LeaveApi({required this.dio}) {
    url = "$baseUrl/leaves.php";
  }

  Future<List<Leave>> getLeaves(String userId) async {
    final res = await dio.get("leaves.php", queryParameters: {"id": userId});
    if (res.statusCode != 200) return [];
    return LeaveReport.fromRawJson(res.data).data;
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
    final res = await dio.post(
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
    final code = res.statusCode ?? 0;
    if (code >= 400 && code < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.data)));
    }
  }

  Future<void> deleteLeaves({
    required String userId,
    required String leaveId,
  }) async {
    final res = await dio.delete("leaves.php",
        queryParameters: {"user_id": userId, "leave_id": leaveId});
    final code = res.statusCode ?? 0;
    if (code >= 400 && code < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.data)));
    }
  }
}
