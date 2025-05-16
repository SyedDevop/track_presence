import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/loan_model.dart';

class LoanApi {
  Dio dio;
  static const String url = "loan.php";
  LoanApi({required this.dio});

  Future<List<Loan>> getLeaves(String userId) async {
    final res = await dio.get(url, queryParameters: {"id": userId});
    if (res.statusCode != 200) return [];
    return LoanReport.formRawJson(res.data).data;
  }

  Future<LoanFullReport?> getLoanReport(String userId, String loanId) async {
    try {
      final query = {"id": userId, "loan_id": loanId};
      final res = await dio.get(url, queryParameters: query);
      return LoanFullReport.formRawJson(res.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<LoanPayment>> getLoanPaymentFromPayrollId(
    String userId,
    int payrollId,
  ) async {
    final query = {"id": userId, "payroll_id": payrollId};
    final res = await dio.get(url, queryParameters: query);
    return loanPaymentListFromJson(res.data);
  }

  Future<void> postLoan({
    required String userId,
    required double amount,
    required String loanType,
    required String department,
  }) async {
    await dio.post(
      url,
      data: json.encode({
        "id": userId,
        "amount": amount,
        "department": department,
        "loan_type": loanType,
      }),
      options: Options(contentType: "application/json"),
    );
  }

  Future<void> deleteLeaves({
    required String loanId,
  }) async {
    await dio.delete(url, queryParameters: {"id": loanId});
  }
}
