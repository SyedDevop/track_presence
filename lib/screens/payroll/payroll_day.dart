import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/services/service.dart';
import 'package:vcare_attendance/utils/utils.dart';
import 'package:vcare_attendance/widgets/ui/frost_glass.dart';

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

  final _appSr = getIt<AppStore>();

  Future<void> _fetchData(String date) async {
    final userId = _appSr.token.id;
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
              color: Colors.greenAccent.withValues(alpha: 0.7)),
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
    final payroll = payrollRaw.payroll ?? payrollRaw.payrolls?.first;
    if (payroll == null) {
      return const Center(child: Text("No payroll data available."));
    }
    final payrollInfo = payrollRaw.info;
    final attendance = payroll.attendance;

    final salaryPerMin = payrollInfo.salaryPerMinute;
    final extratimePay = payroll.extratimeMin * salaryPerMin;
    final dailyPay = attendance.workedMin * salaryPerMin;
    final totalPay = dailyPay + extratimePay;

    // Cache the dynamic color value.
    final payrollColor = payroll.payrollRawColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            payroll.day(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          FrostedGlass(
            borderColor: payrollColor.withValues(alpha: 0.3),
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
                _infoTextPay(
                  "Shift Hours",
                  (attendance.shiftMin),
                  (attendance.shiftMin * salaryPerMin),
                  textColor: Colors.white60,
                ),
                const Divider(),
                const SizedBox(height: 10),
                _infoTextPay(
                  "Worked Hours",
                  (attendance.workedMin),
                  (attendance.workedMin * salaryPerMin),
                  payColor: Colors.greenAccent,
                ),
                _infoTextPay(
                  "Late In",
                  (attendance.lateInLohMin),
                  (attendance.lateInLohMin * salaryPerMin),
                  payColor: Colors.redAccent,
                ),
                _infoTextPay(
                  "Late Out",
                  (attendance.lateOutOtMin),
                  (attendance.lateOutOtMin * salaryPerMin),
                  otMetric: payroll.otMetrics.lateOut,
                  payColor: Colors.greenAccent,
                ),
                _infoTextPay(
                  "Early In",
                  (attendance.earlyInOtMin),
                  (attendance.earlyInOtMin * salaryPerMin),
                  otMetric: payroll.otMetrics.earlyIn,
                  payColor: Colors.greenAccent,
                ),
                _infoTextPay(
                  "Early Out",
                  (attendance.earlyOutLohMin),
                  (attendance.earlyOutLohMin * salaryPerMin),
                  payColor: Colors.redAccent,
                ),
                const Divider(),
                _infoTextPay(
                  "Extra Hours",
                  payroll.extratimeMin,
                  payroll.extratimeMin * salaryPerMin,
                  payColor: Colors.greenAccent,
                ),
                const Divider(),
                const SizedBox(height: 10),
                _infoText("Total Salary", fmtInr(totalPay)),
              ],
            ),
          ),
          // const SizedBox(height: 25),
          // const Text(
          //   "*The overtime pay is not included yet. Your admin needs to confirm the overtime hours, and it will be calculated at the end of the month.",
          //   style: TextStyle(
          //     color: Colors.red,
          //   ),
          // ),
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

  Widget _infoTextPay(
    String leadingText,
    int time,
    double pay, {
    OtMetric? otMetric,
    Color textColor = Colors.white,
    Color? payColor,
  }) {
    final hasOt = otMetric != null;
    final textStyle = TextStyle(color: payColor ?? textColor);
    final payStrick = hasOt
        ? textStyle.copyWith(
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          )
        : textStyle;
    final timeStrick = hasOt
        ? textStyle.copyWith(
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          )
        : TextStyle(color: textColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            leadingText,
            style: TextStyle(
              color: textColor,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      minToHrMin(time),
                      style: timeStrick,
                    ),
                    Text(
                      fmtInr(pay),
                      style: payStrick,
                    ),
                  ],
                ),
              ),
              if (hasOt)
                SizedBox(
                  width: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        minToHrMin(otMetric.minutes),
                      ),
                      Text(
                        fmtInr(otMetric.pay),
                        style: textStyle,
                      ),
                    ],
                  ),
                ),
            ],
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
