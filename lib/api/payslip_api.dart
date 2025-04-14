import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/models/payslip_model.dart';

class PayslipApi {
  String baseUrl;
  late String url;
  PayslipApi({required this.baseUrl}) {
    url = "$baseUrl/payroll.php";
  }

  Future<void> deletePayslip(int id) async {
    final response = await http.delete(Uri.parse('$url/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete payslip');
    }
  }

  Future<Payslip?> fetchPayslipsByMonthAndYear(
    String userId,
    String month,
    int year,
  ) async {
    final payslipUrl = '$url?id=$userId&month=$month&year=$year';
    final response = await http.get(Uri.parse(payslipUrl));
    if (response.statusCode != 200) return null;
    return Payslip.fromRawJson(response.body);
  }

  Future<String?> downloadPayslip(int payslipId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/../generate/payslip_pdf.php?id=$payslipId"));
      if (res.statusCode != 200) throw "Error: Failed to download the payslip";

      String? contentDisposition = res.headers['content-disposition'];
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

        await file.writeAsBytes(res.bodyBytes);
        return "Your payslip '$filename' is ready! Find it at: $filePath.";
      }
    } catch (e) {
      print("[Error]: #downloadPayslip catch:error = $e");
      throw "Error: Unknow error accoured try again later";
    }
    return null;
  }

  Future<PayrollRaw?> getRawPayroll(String id, String date) async {
    final res = await http.get(
      Uri.parse('$baseUrl/payslip.php?id=$id&day=$date'),
    );
    if (res.statusCode != 200) return null;
    return PayrollRaw.fromRawJson(res.body);
  }
}
