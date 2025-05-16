import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/models/payslip_model.dart';

class PayslipApi {
  Dio dio;
  static const String url = "payroll.php";
  PayslipApi({required this.dio});

  Future<void> deletePayslip(int id) async {
    await dio.delete("$url/$id");
  }

  Future<Payslip?> fetchPayslipsByMonthAndYear(
    String userId,
    String month,
    int year,
  ) async {
    final query = {"id": userId, "month": month, "year": year};
    final response = await dio.get(url, queryParameters: query);
    return Payslip.fromRawJson(response.data);
  }

  // TODO: Use Dio downloads method.
  Future<String?> downloadPayslip(int payslipId) async {
    try {
      final res = await dio.get("../generate/payslip_pdf.php",
          queryParameters: {"id": payslipId},
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
          ));
      if (res.statusCode != 200) throw "Error: Failed to download the payslip";

      String? contentDisposition = res.headers.value('content-disposition');
      String filename = "payslip_$payslipId.pdf";
      if (contentDisposition != null &&
          contentDisposition.contains('filename=')) {
        filename =
            contentDisposition.split('filename=')[1].replaceAll('"', '').trim();

        // Directory? downloadsDir = await getExternalStorageDirectory();
        // if (downloadsDir == null) {
        //   throw "Error: Could not get downloads directory";
        // }

        // String filePath = '${downloadsDir.path}/$filename';
        String filePath = "/storage/emulated/0/Download/$filename";
        File file = File(filePath);

        await file.writeAsBytes(res.data);
        return "Your payslip '$filename' is ready! Find it at: $filePath.";
      }
    } catch (e) {
      print("[Error]: #downloadPayslip catch:error = $e");
      throw "Error: Unknow error accoured try again later";
    }
    return null;
  }

  Future<PayrollRaw?> getRawPayroll(String id, String date) async {
    try {
      final query = {"id": id, "date": date};
      final res = await dio.get("payslip.php", queryParameters: query);
      return PayrollRaw.fromRawJson(res.data);
    } catch (e) {
      return null;
    }
  }

  Future<PayrollRaw?> getRawPayrolls(
    String id,
    String month,
    int year,
  ) async {
    try {
      final query = {"id": id, "month": month, "year": year};
      final res = await dio.get("payslip.php", queryParameters: query);
      return PayrollRaw.fromRawJson(res.data);
    } catch (e) {
      return null;
    }
  }
}
