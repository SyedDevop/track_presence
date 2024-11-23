// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/models/shift_report_modeal.dart';
import 'package:vcare_attendance/models/time.dart';

const baseApi = "https://vcarehospital.in/hms1/payroll/api";
String toDay() {
  return DateFormat('dd-MM-yyyy').format(DateTime.now());
}

String toDay2() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class Api {
  static Future<Profile?> login(String id, String password) async {
    final res = await http.post(
      Uri.parse('$baseApi/login.php'),
      body: json.encode({"id": id, "password": password}),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }

    final jsBody = jsonDecode(res.body);
    print(jsBody);
    return Profile.fromApiJson(jsBody["profile"]);
  }

  static Future<ShiftReport?> getShifts(
      String id, String fromDate, String toDate) async {
    try {
      final res = await http.post(
        Uri.parse('$baseApi/get_shifts.php'),
        body: json.encode(
          {"id": id, "from-date": fromDate, "to-date": toDate},
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode != 200) return null;
      return ShiftReport.fromRawJson(res.body);
    } catch (e) {
      print("Error geting Shifts data: $e");
      return null;
    }
  }

  static Future<List<String>> getDepartments() async {
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_departments.php'),
      );
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body)["data"];
      return (data as List<dynamic>).map((e) => e.toString()).toList();
    } catch (e) {
      print("Error geting Profile data: $e");
      return [];
    }
  }

  static Future<List<(String, String)>> getEmployes(String department) async {
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_employees.php?department=$department'),
      );
      if (res.statusCode != 200) return [];
      Map<String, dynamic> jsonData = jsonDecode(res.body);
      final result = (jsonData['data'] as Map<String, dynamic>)
          .entries
          .map((entry) => (entry.key, entry.value as String))
          .toList();
      return result;
    } catch (e) {
      print("Error geting Profile data: $e");
      return [];
    }
  }

  static Future<Report?> getReport(
    /// [employee] in employee name and id in this formate ex:"name-id"  separated to dash
    String employee,

    /// [month] name of the month ex:"November"
    String month,

    /// [year] the in full formate yyyy ex:"2014"
    int year,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseApi/get_report.php'),
        body: json.encode(
          {"employee_id": employee, "month": month, "year": year},
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

  static Future<Profile?> getProfile(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseApi/employee_by_id.php?id=$id'),
      );
      if (res.statusCode != 200) return null;
      return Profile.fromApiJson(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }

  static Future<ShiftTime?> getShifttime(String id) async {
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_shifttime.php?id=$id'),
      );
      if (res.statusCode != 200) return null;
      return ShiftTime.fromMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }

  static Future<void> postColock(
    String id,
    String clockType,
    String reason,
  ) async {
    final reas = reason.isEmpty ? null : reason;
    final res = await http.post(
      Uri.parse('$baseApi/clock_attendance.php?id=$id&clock=$clockType'),
      body: reas == null ? null : json.encode({"reason": reason}),
      headers: {"Content-Type": "application/json"},
    );
    // print(res.body);
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }

  static Future<Attendance?> getColockedtime(String id, {String? date}) async {
    final getDate = date ?? toDay();
    print({"From ": "ClockedTime", "toDay": getDate});
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_attendance.php?id=$id&date=$getDate'),
      );
      print(res.body);
      if (res.statusCode != 200) return null;
      return Attendance.fromMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }

  static Future<List<ExtraHours>> getOvertime(String id, {String? date}) async {
    final getDate = date ?? toDay2();
    print({"From ": "Over Time", "toDay": getDate});
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_attendance_ot.php?id=$id&date=$getDate'),
      );
      print(res.body);
      if (res.statusCode != 200) return [];
      return ExtraHours.fromArrayMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return [];
    }
  }
}
