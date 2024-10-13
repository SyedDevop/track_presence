// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:track_presence/models/profile_model.dart';
import 'package:track_presence/models/time.dart';

const baseApi = "https://vcarehospital.in/hms/payroll/api";
String toDay() {
  final t = DateTime.now();
  return "${t.day}-${t.month}-${t.year}";
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

// get_attendance.php?id=VCH0170&date=09-10-2024
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

  static Future<void> postColock(String id, String clockType) async {
    final res = await http.post(
      Uri.parse('$baseApi/clock_attendance.php?id=$id&clock=$clockType'),
    );
    print(res.body);
    if (res.statusCode != 200) {
      throw ApiException(jsonDecode(res.body)['message']);
    }
  }

  static Future<ClockedTime?> getColockedtime(String id, {String? date}) async {
    final getDate = date ?? toDay();
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
}
