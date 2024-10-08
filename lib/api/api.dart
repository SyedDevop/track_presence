import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:track_presence/models/profile_model.dart';

class Api {
  static Future<Profile?> getProfile(String id) async {
    try {
      final res = await http.get(Uri.parse(
        'https://vcarehospital.in/hms/payroll/api/employee_by_id.php?id=$id',
      ));
      if (res.statusCode != 200) return null;
      return Profile.fromApiJson(jsonDecode(res.body));
    } catch (e) {
      print("Error geting Profile data: $e");
      return null;
    }
  }
}
