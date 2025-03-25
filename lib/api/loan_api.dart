import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/models/loan_model.dart';

class LoanApi {
  String baseUrl;
  late String url;
  LoanApi({required this.baseUrl}) {
    url = "$baseUrl/loan.php";
  }

  Future<List<Loan>> getLeaves(String userId) async {
    final res = await http.get(Uri.parse('$url?id=$userId'));
    if (res.statusCode != 200) return [];
    return LoanReport.formRawJson(res.body).data;
  }

  Future<void> postLoan({
    required String userId,
    required double amount,
    required String loanType,
    required String department,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      body: json.encode({
        "id": userId,
        "amount": amount,
        "department": department,
        "loan_type": loanType,
      }),
      headers: {"Content-Type": "application/json"},
    );
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }

  Future<void> deletLeaves({
    required String loanId,
  }) async {
    final res = await http.delete(Uri.parse("$url?id=$loanId"));
    if (res.statusCode >= 400 && res.statusCode < 500) {
      throw ApiException(ApiError.fromJson(jsonDecode(res.body)));
    }
  }
}
