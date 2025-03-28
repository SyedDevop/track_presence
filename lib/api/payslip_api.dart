import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/models/payslip_model.dart';

class PayslipApi {
  static const String baseUrl = 'https://api.example.com/payslips';
  late String url;
  PayslipApi({required String baseUrl}) {
    url = "$baseUrl/payslip.php";
  }

  Future<void> deletePayslip(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete payslip');
    }
  }

  Future<Payslip?> fetchPayslipsByMonthAndYear(
    String userId,
    String month,
    int year,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl?id=$userId&month=$month&year=$year'),
    );
    if (response.statusCode != 200) return null;
    return Payslip.fromRawJson(response.body);
  }

  Future<List<Payslip>> fetchPayslipsByEmployeeId(String empId) async {
    final response = await http.get(Uri.parse('$baseUrl?emp_id=$empId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((payslip) => Payslip.fromJson(payslip)).toList();
    } else {
      throw Exception('Failed to load payslips');
    }
  }
}
