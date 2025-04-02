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
    final attendance = payroll.attendance;

    final salaryPerMin = payrollInfo.salaryPerMinute;
    final overtimePay = payroll.overtimeMin * salaryPerMin;
    final dailyPay = attendance.attendanceMin * salaryPerMin;
    final totalPay = dailyPay + overtimePay;

    // Cache the dynamic color value.
    final payrollColor = payroll.payrollRawColor();

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
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(
                    color: payrollColor.withOpacity(0.3),
                    width: 2.5,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        payroll.todayIs(),
                        style: TextStyle(
                          color: payrollColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      _infoTextPrice(
                        "Shift Hours",
                        minToHrMin(attendance.shiftMin),
                        fmtInr(attendance.shiftMin * salaryPerMin),
                        textColor: Colors.white60,
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      _infoTextPrice(
                        "Worked Hours",
                        minToHrMin(attendance.attendanceMin),
                        fmtInr(attendance.attendanceMin * salaryPerMin),
                      ),
                      _infoTextPrice(
                        "Loss Of Hours",
                        minToHrMin(attendance.attendanceLOHMin),
                        fmtInr(attendance.attendanceLOHMin * salaryPerMin),
                      ),
                      _infoTextPrice(
                        "OverTime Hours",
                        minToHrMin(attendance.attendanceOTMin),
                        fmtInr(attendance.attendanceOTMin * salaryPerMin),
                      ),
                      _infoTextPrice(
                        "Extra Hours",
                        minToHrMin(payroll.overtimeMin),
                        fmtInr(payroll.overtimeMin * salaryPerMin),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      _infoText(
                        "Total Salary",
                        fmtInr(totalPay),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "*The overtime pay is not included yet. Your admin needs to confirm the overtime hours, and it will be calculated at the end of the month.",
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String leadingText, String trailingText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leadingText,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          Text(
            trailingText,
            style: const TextStyle(
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _infoTextPrice(
    String leadingText,
    String timeText,
    String priceText, {
    Color textColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            leadingText,
            style: TextStyle(
              color: textColor,
            ),
          ),
          SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                Text(
                  priceText,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
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
