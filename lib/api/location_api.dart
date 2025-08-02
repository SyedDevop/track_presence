import 'dart:convert';

import 'package:dio/dio.dart';

enum AttendanceType { otAttendance, attendance }

class LocationApi {
  final Dio dio;
  const LocationApi({required this.dio});

  Future<void> postLocation(
    String lat,
    String lon,
    AttendanceType attType,
    String attId,
  ) async {
    await dio.post(
      'location.php',
      data: json.encode({
        "lat": lat,
        "lon": lon,
        "att-type": attType.name,
        "att-id": attId,
        "ofline": false,
      }),
      options: Options(contentType: "application/json"),
    );
  }
}
