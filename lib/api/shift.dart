import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/models/shift_report_modeal.dart';
import 'package:vcare_attendance/models/time.dart';

class ShiftApi {
  String baseUrl;
  late String shiftTimeurl;
  late String shifturl;
  ShiftApi({required this.baseUrl}) {
    shifturl = "$baseUrl/get_shifts.php";
    shiftTimeurl = "$baseUrl/get_shifttime.php";
  }

  Future<ShiftReport?> getShifts(
    String id,
    String fromDate,
    String toDate,
  ) async {
    try {
      final res = await http.post(
        Uri.parse(shifturl),
        body: json.encode(
          {"id": id, "from-date": fromDate, "to-date": toDate},
        ),
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
    print("Getting ShiftTime $id");
    try {
      final res = await http.get(
        Uri.parse('$shiftTimeurl?id=$id'),
      );
      print({"ShiftTime Res": res.statusCode});
      if (res.statusCode != 200) return null;
      return ShiftTime.fromMap(jsonDecode(res.body));
    } catch (e) {
      print("Error geting shiftTime data: $e");
      return null;
    }
  }
}
