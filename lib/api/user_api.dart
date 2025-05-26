import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/empolyee_modeal.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class UserApi {
  Dio dio;
  UserApi({required this.dio});

  Future<Employee?> getEmployee(String id) async {
    try {
      final res = await dio.get(
        "get_employees_details.php",
        queryParameters: {"id": id},
      );
      final data = (res.data)["data"];
      return Employee.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getDepartments() async {
    try {
      final res = await dio.get("get_departments.php");
      final data = res.data["data"];
      return (data as List<dynamic>).map((e) => e.toString()).toList();
    } catch (e) {
      print("[Error] getting Department data: $e");
      return [];
    }
  }

  Future<List<(String, String)>> getEmployes(String department) async {
    try {
      final res = await dio.get(
        "get_employees.php",
        queryParameters: {"department": department},
      );
      Map<String, dynamic> jsonData = res.data;
      final result = (jsonData['data'] as Map<String, dynamic>)
          .entries
          .map((entry) => (entry.key, entry.value as String))
          .toList();
      return result;
    } catch (e) {
      print("[Error] getting Employees data: $e");
      return [];
    }
  }

  Future<Profile?> getProfile(String id) async {
    try {
      final res = await dio.get(
        "employee_by_id.php",
        queryParameters: {"id": id},
      );
      return Profile.fromApiJson(res.data);
    } catch (e) {
      print("[Error] getting Profile data: $e");
      return null;
    }
  }
}
