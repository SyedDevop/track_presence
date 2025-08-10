import 'dart:convert';

import 'package:dio/dio.dart';

enum AttendanceType { otAttendance, attendance }

class LocationApi {
  final Dio dio;
  const LocationApi({required this.dio});

  Future<void> postLocation(
    double lat,
    double long,
    int? attId,
    int? otAttId,
    bool offline,
  ) async {
    // assert(
    //   attId == null && otAttId == null,
    //   "[Assert] LocationApi otAttId and attId can't be null at the same time",
    // );
    await dio.post(
      'location.php',
      data: json.encode({
        "lat": lat,
        "long": long,
        "att-id": attId,
        "ot-att-id": otAttId,
        "ofline": offline,
      }),
      options: Options(contentType: "application/json"),
    );
  }
}
