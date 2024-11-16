// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/time.dart';

const baseApi = "https://vcarehospital.in/hms/payroll/api";
String toDay() {
  return DateFormat('dd-MM-yyyy').format(DateTime.now());
}

String toDay2() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}

class Api {
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

  static Future<ClockedTime?> getColockedtime(String id, {String? date}) async {
    final getDate = date ?? toDay();
    print({"From ": "ClockedTime", "toDay": getDate});
    try {
      final res = await http.get(
        Uri.parse('$baseApi/get_attendance.php?id=$id&date=$getDate'),
      );
      print(res.body);
      if (res.statusCode != 200) return null;
      return ClockedTime.fromMap(jsonDecode(res.body));
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
