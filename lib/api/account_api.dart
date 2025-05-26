import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

class AccountApi {
  Dio dio;
  AccountApi({required this.dio});

  Future<void> authState() async {
    await dio.post(
      "auth_state.php",
      options: Options(contentType: "application/json"),
    );
  }

  Future<Map<String, dynamic>> login(String userId, String password) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final res = await dio.post(
      "login.php",
      data: json.encode({
        "user-id": userId,
        "password": password,
        "device_name": androidInfo.model,
        "device_id": androidInfo.id
      }),
      options: Options(contentType: "application/json"),
    );
    return res.data;
  }

  Future<void> changePassword(
      String userId, String currPassword, String password) async {
    await dio.post(
      "forgot_password.php",
      data: json.encode({
        "user-id": userId,
        "curr-password": currPassword,
        "password": password
      }),
      options: Options(contentType: "application/json"),
    );
  }
}
