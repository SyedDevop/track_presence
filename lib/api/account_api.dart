import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/api/error.dart';

import 'package:vcare_attendance/models/profile_model.dart';

class AccountApi {
  String baseUrl;
  late String url;
  AccountApi({required this.baseUrl}) {
    url = "$baseUrl/account.php";
  }

  Future<Profile?> login(String userId, String password) async {
    final res = await http.post(
      Uri.parse("$url?action=login"),
      body: json.encode({"user-id": userId, "password": password}),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
    final jsBody = jsonDecode(res.body);
    return Profile.fromApiJson(jsBody["profile"]);
  }

  Future<void> changePassword(
      String userId, String currPassword, String password) async {
    final res = await http.post(
      Uri.parse("$url?action=change_password"),
      body: json.encode({
        "user-id": userId,
        "curr-password": currPassword,
        "password": password
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }
}
