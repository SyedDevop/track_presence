import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/models/time.dart';

String toDay() {
  return DateFormat('dd-MM-yyyy').format(DateTime.now());
}

String toDay2() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class AttendanceApi {
  final Dio dio;
  const AttendanceApi({required this.dio});

  Future<Attendance?> getColockedtime(String id, {String? date}) async {
    final getDate = date ?? toDay2();
    try {
      final res = await dio.get(
        "get_attendance.php",
        queryParameters: {"id": id, "date": getDate},
      );
      return Attendance.fromMap(res.data);
    } catch (e) {
      print("[Error] getting Profile data: $e");
      return null;
    }
  }

  Future<List<ExtraHours>> getOvertime(String id, {String? date}) async {
    final getDate = date ?? toDay2();
    try {
      final res = await dio.get(
        "get_attendance_ot.php",
        queryParameters: {"id": id, "date": getDate},
      );
      return ExtraHours.fromArrayMap(res.data);
    } catch (e) {
      print("[Error] getting OverTime data: $e");
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
    await dio.post(
      'attandance/attandance.php',
      queryParameters: {
        "id": id,
        "clock": clockType,
        "location": location,
        "authType": authType
      },
      data: reas == null ? null : json.encode({"reason": reason}),
      options: Options(contentType: "application/json"),
    );
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
      final res = await dio.post(
        "get_report.php",
        data: json
            .encode({"employee_id": employee, "month": month, "year": year}),
        options: Options(contentType: "application/json"),
      );
      return Report.fromJson(res.data);
    } catch (e) {
      print("[Error] getting Report data: $e");
      return null;
    }
  }
}
