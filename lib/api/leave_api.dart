import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/api/error.dart';

import 'package:vcare_attendance/models/leave_model.dart';

class LeaveApi {
  String baseUrl;
  late String url;
  LeaveApi({required this.baseUrl}) {
    url = "$baseUrl/leaves.php";
  }

  Future<List<Leave>> getLeaves(String userId) async {
    final res = await http.get(Uri.parse('$url?id=$userId'));
    if (res.statusCode != 200) return [];
    return LeaveReport.fromRawJson(res.body).data;
  }

  Future<void> postLeaves({
    required String userId,
    required String name,
    required String fromDate,
    required String toDate,
    required String reason,
    required String department,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      body: json.encode({
        "id": userId,
        "name": name,
        "from-date": fromDate,
        "to-date": toDate,
        "reason": reason,
        "department": department
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }

  Future<void> deletLeaves({
    required String userId,
    required String leaveId,
  }) async {
    final res =
        await http.delete(Uri.parse("$url?user_id=$userId&leave_id$leaveId"));
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }
}
