import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vcare_attendance/api/error.dart';

import 'package:vcare_attendance/models/profile_model.dart';

class AccountApi {
  Dio dio;
  AccountApi({required this.dio});

  Future<Profile?> login(String userId, String password) async {
    final res = await dio.post(
      "login.php",
      data: json.encode({"user-id": userId, "password": password}),
      options: Options(contentType: "application/json"),
    );
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.data)));
    }
    final jsBody = jsonDecode(res.data);
    return Profile.fromApiJson(jsBody["profile"]);
  }

  Future<void> changePassword(
      String userId, String currPassword, String password) async {
    final res = await dio.post("forgot_password.php",
        data: json.encode({
          "user-id": userId,
          "curr-password": currPassword,
          "password": password
        }),
        options: Options(contentType: "application/json"));
    if (res.statusCode != null &&
        res.statusCode! >= 400 &&
        res.statusCode! < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.data)));
    }
  }
}
