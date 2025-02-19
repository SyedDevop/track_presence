import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/models/shift_report_modeal.dart';
import 'package:vcare_attendance/models/time.dart';

class ShiftApi {
  String baseUrl;
  late String shiftTimeUrl;
  late String shiftUrl;
  ShiftApi({required this.baseUrl}) {
    shiftUrl = "$baseUrl/get_shifts.php";
    shiftTimeUrl = "$baseUrl/get_shifttime.php";
  }

  Future<ShiftReport?> getShifts(
    String id,
    String fromDate,
    String toDate,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(shiftUrl),
        body: json.encode({"id": id, "from-date": fromDate, "to-date": toDate}),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode != 200) return null;
      return ShiftReport.fromRawJson(res.body);
    } catch (e) {
      print("Error geting Shifts data: $e");
      return null;
    }
  }

  Future<ShiftTime?> getShifttime(String id) async {
    try {
      final res = await http.get(Uri.parse('$shiftTimeUrl?id=$id'));
      if (res.statusCode != 200) return null;
      return ShiftTime.fromMap(jsonDecode(res.body));
    } catch (e) {
      print("[Error] Api shift geting shiftTime data: $e");
      return null;
    }
  }
}
