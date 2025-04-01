import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/utils/utils.dart';

class PayrollDayScreen extends StatefulWidget {
  const PayrollDayScreen({super.key});

  @override
  State<PayrollDayScreen> createState() => _PayrollDayScreenState();
}

class _PayrollDayScreenState extends State<PayrollDayScreen> {
  final apip = Api.payslip;
  bool _loading = false;
  String _selectedDate = "";
  PayrollRaw? payslipRaw;

  final profile = getIt<AppState>().profile;

  Future<void> _fetchData(String date) async {
    final userId = profile?.userId ?? "";
    setState(() {
      _loading = true;
      _selectedDate = date;
    });
    final res = await apip.getRawPayroll(userId, date);
    if (res != null) setState(() => payslipRaw = res);
    setState(() => _loading = false);
  }

  Widget _getBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (payslipRaw == null) {
      return Center(
        child: Text(
          "Select a date to view payroll details.....",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.greenAccent.withOpacity(0.7)),
        ),
      );
    }
    return PayrollDayRawBody(
      selectedDate: _selectedDate,
      payrollRaw: payslipRaw!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSubmit,
        child: const Icon(Icons.search_rounded),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    await _showDateSheet(context);
  }

  Future<void> _showDateSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.single,
          showTodayButton: true,
          showActionButtons: true,
          toggleDaySelection: true,
          maxDate: DateTime.now(),
          onCancel: () => context.pop(),
          onSubmit: (Object? value) {
            if (mounted) context.pop();
            if (value is DateTime) {
              final selectedDate = dateFmt.format(value);
              _fetchData(selectedDate);
            }
          },
        ),
      ),
    );
  }
}

class PayrollDayRawBody extends StatelessWidget {
  const PayrollDayRawBody({
    super.key,
    required this.selectedDate,
    required this.payrollRaw,
  });

  final String selectedDate;
  final PayrollRaw payrollRaw;

  @override
  Widget build(BuildContext context) {
    final payroll = payrollRaw.payroll;
    final payrollInfo = payrollRaw.info;

    double overtimePay = payroll.overtimeMin * payrollInfo.salaryPerMinute;
    double dailyPay =
        payroll.attendance.attendanceMin * payrollInfo.salaryPerMinute;
    double totalPay = dailyPay + overtimePay;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            selectedDate,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: payroll.payrollRawColor2().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: payroll.payrollRawColor2().withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoText('Overtime: ${payroll.overtimeMin} mins'),
                        _infoText(
                            'Shift Minutes: ${payroll.attendance.shiftMin}'),
                        _infoText(
                            'Attendance Minutes: ${payroll.attendance.attendanceMin}'),
                        const Divider(color: Colors.white54),
                        _infoText(
                            'Basic Salary: \$${payrollInfo.basicSalary.toStringAsFixed(2)}'),
                        _infoText(
                            'Daily Salary: \$${dailyPay.toStringAsFixed(2)}'),
                        _infoText(
                            'Overtime Pay: \$${overtimePay.toStringAsFixed(2)}'),
                        _infoText('Total Pay: \$${totalPay.toStringAsFixed(2)}',
                            bold: true),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}


// class PayrollDayRawBody extends StatelessWidget {
//   const PayrollDayRawBody({
//     super.key,
//     required this.selectedDate,
//     required this.payrollRaw,
//   });
//
//   final String selectedDate;
//   final PayrollRaw payrollRaw;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             selectedDate,
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueAccent,
//             ),
//           ),
//           Expanded(
//             child: Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15)),
//               elevation: 5,
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: _determineGradientColors(),
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   List<Color> _determineGradientColors() {
//     if (payrollRaw.isLeave) {
//       return [Colors.blue.shade400, Colors.blue.shade700];
//     } else if (payrollRaw.isHoliday) {
//       return [Colors.amber.shade600, Colors.amber.shade900];
//     } else if (payrollRaw.isAbsent) {
//       return [Colors.red.shade600, Colors.red.shade900];
//     } else {
//       return [Colors.green.shade500, Colors.green.shade800];
//     }
//   }
// }
