import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/models/time.dart';

String toDay() {
  return DateFormat('dd-MM-yyyy').format(DateTime.now());
}

String toDay2() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class AttendanceApi {
  final String baseUrl;
  const AttendanceApi({required this.baseUrl});

  Future<Attendance?> getColockedtime(String id, {String? date}) async {
    final getDate = date ?? toDay2();
    print({"From ": "ClockedTime", "toDay": getDate});
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/get_attendance.php?id=$id&date=$getDate'),
      );
      print(res.body);
      if (res.statusCode != 200) return null;
      return Attendance.fromMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }

  Future<List<ExtraHours>> getOvertime(String id, {String? date}) async {
    final getDate = date ?? toDay2();
    print({"From ": "Over Time", "toDay": getDate});
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/get_attendance_ot.php?id=$id&date=$getDate'),
      );
      print(res.body);
      if (res.statusCode != 200) return [];
      return ExtraHours.fromArrayMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return [];
    }
  }

  Future<void> postColock(
    String id,
    String clockType,
    String reason,
    String location,
    String authType,
  ) async {
    final reas = reason.isEmpty ? null : reason;
    final res = await http.post(
      Uri.parse(
        '$baseUrl/attandance/attandance.php?id=$id&clock=$clockType&location=$location&authType=$authType',
      ),
      body: reas == null ? null : json.encode({"reason": reason}),
      headers: {"Content-Type": "application/json"},
    );
    print("[Info] postColock res body :: ${res.body}");
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }

  Future<Report?> getReport(
    /// [employee] in employee name and id in this formate ex:"name-id"  separated to dash
    String employee,

    /// [month] name of the month ex:"November"
    String month,

    /// [year] the in full formate yyyy ex:"2014"
    int year,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/get_report.php'),
        body: json.encode(
          {"employee_id": employee, "month": month, "year": year}
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode != 200) return null;
      final result = Report.fromRawJson(res.body);
      return result;
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }
}
