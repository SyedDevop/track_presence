import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:vcare_attendance/models/empolyee_modeal.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class UserApi {
  Dio dio;
  UserApi({required this.dio});

  Future<Employee?> getEmployee(String id) async {
    final res = await dio.get(
      "get_employees_details.php",
      queryParameters: {"id": id},
    );
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.data)["data"];
    return Employee.fromJson(data);
  }

  Future<List<String>> getDepartments() async {
    try {
      final res = await dio.get("get_departments.php");
      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.data)["data"];
      return (data as List<dynamic>).map((e) => e.toString()).toList();
    } catch (e) {
      print("Error geting Profile data: $e");
      return [];
    }
  }

  Future<List<(String, String)>> getEmployes(String department) async {
    try {
      final res = await dio.get(
        "get_employees.php",
        queryParameters: {"department": department},
      );
      if (res.statusCode != 200) return [];
      Map<String, dynamic> jsonData = jsonDecode(res.data);
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

  Future<Profile?> getProfile(String id) async {
    try {
      final res = await dio.get(
        "employee_by_id.php",
        queryParameters: {"id": id},
      );
      if (res.statusCode != 200) return null;
      return Profile.fromApiJson(jsonDecode(res.data));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }
}
