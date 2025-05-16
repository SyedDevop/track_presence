import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/shift_report_modeal.dart';
import 'package:vcare_attendance/models/time.dart';
import 'package:vcare_attendance/utils/utils.dart';

class ShiftApi {
  late String baseUrl;
  static const String shiftTimeUrl = "get_shifttime.php";
  static const String shiftUrl = "get_shifts.php";
  Dio dio;
  ShiftApi({required this.dio});

  Future<ShiftReport?> getShifts(
    String id,
    String fromDate,
    String toDate,
  ) async {
    try {
      final res = await dio.post(
        shiftUrl,
        data: json.encode({"id": id, "from-date": fromDate, "to-date": toDate}),
        options: Options(contentType: "application/json"),
      );
      return ShiftReport.fromRawJson(res.data);
    } catch (e) {
      print("[Error] Getting Shifts data: $e");
      return null;
    }
  }

  Future<ShiftTime?> getShifttime(String id) async {
    final toDay = dateFmtDMY.format(DateTime.now());
    try {
      final res = await dio.get(
        shiftTimeUrl,
        queryParameters: {"id": id, "date": toDay},
      );
      return ShiftTime.fromMap(jsonDecode(res.data));
    } catch (e) {
      print("[Error] Api shift getting shiftTime data: $e");
      return null;
    }
  }
}
