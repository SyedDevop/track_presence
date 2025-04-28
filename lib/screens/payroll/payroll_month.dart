import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/main.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/utils/utils.dart';
import 'package:vcare_attendance/widgets/ui/frost_glass.dart';
import 'package:vcare_attendance/widgets/widget.dart';

class PayrollMonthScreen extends StatefulWidget {
  const PayrollMonthScreen({super.key});

  @override
  State<PayrollMonthScreen> createState() => _PayrollMonthScreenState();
}

class _PayrollMonthScreenState extends State<PayrollMonthScreen> {
  final apiP = Api.payslip;
  bool _loading = false;

  String _selectedPeriod = "";
  List<dynamic> formattedPayroll = [];
  PayrollTotal payrollTotal = PayrollTotal.empty();
  final profile = getIt<AppState>().profile;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedYear = DateTime.now().year;
  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - 1 + index,
  );

  final _monthDP = GlobalKey<DropdownSearchState<String>>();
  final _yearDP = GlobalKey<DropdownSearchState<int>>();
  final _formKey = GlobalKey<FormState>();

  int currYear = DateTime.now().year;
  int yearLinit = 10;
  int year = DateTime.now().year;
  String month = kMonths[DateTime.now().month - 1];

  Future<void> fetchData(String month, int year) async {
    final userId = profile?.userId ?? "";
    setState(() {
      _loading = true;
    });
    try {
      final res = await apiP.getRawPayrolls(
        userId,
        month,
        year,
      );
      if (res != null) {
        final payroll = res.generateFormatPayrolls();
        setState(() {
          formattedPayroll = payroll.$1;
          payrollTotal = payroll.$2;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _filterForm(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            label: const Text("View Payroll"),
                            icon: const Icon(Icons.receipt_long_sharp),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverToBoxAdapter(
                            child: PayrollTotalCard(total: payrollTotal)),
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        SliverList.builder(
                          itemCount: formattedPayroll.length,
                          itemBuilder: (context, index) {
                            final fmtP = formattedPayroll[index];
                            if (fmtP is FormattedPayroll) {
                              return PayrollPresentCard(fmtP: fmtP);
                            } else if (fmtP is FormattedPayrollSpecial) {
                              final chipColor =
                                  fmtP.type == "Absent" ? null : Colors.black;
                              final color = fmtP.typeColor();
                              return PayrollSpecialCard(
                                color: color,
                                fmtPs: fmtP,
                                chipColor: chipColor,
                              );
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSubmit,
        child: const Icon(Icons.search_rounded),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _selectedPeriod = "$month, $year";
      await fetchData(month, year);
    }
  }

  SizedBox _filterForm() {
    return SizedBox(
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 15,
          children: [
            SizedBox(
              width: 200,
              child: AtDropdown<String>(
                dropdownKey: _monthDP,
                selectedItem: month,
                labelText: "Select Month",
                hintText: "select a month.",
                validationErrorText: "month is required.",
                items: (f, cs) => kMonths,
                onChanged: (p0) {
                  if (p0 != null) {
                    month = p0;
                  }
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: AtDropdown<int>(
                dropdownKey: _yearDP,
                selectedItem: year,
                labelText: "Select Year",
                hintText: "select a year.",
                validationErrorText: "year is required.",
                items: (f, cs) => List.generate(yearLinit, (i) => currYear - i),
                onChanged: (p0) {
                  if (p0 != null) {
                    year = p0;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const monthDayStyle = TextStyle(
  fontWeight: FontWeight.bold,
);

class PayrollPresentCard extends StatelessWidget {
  const PayrollPresentCard({
    super.key,
    required this.fmtP,
  });

  final FormattedPayroll fmtP;

  @override
  Widget build(BuildContext context) {
    final approvedLateOut =
        fmtP.approvedLateOutPay != null && fmtP.approvedLateOutMins != null;
    final approvedEarlyIn =
        fmtP.approvedEarlyInPay != null && fmtP.approvedEarlyInMins != null;
    print(
        "Approved Early In: $approvedEarlyIn Approved Late Out: $approvedLateOut \n");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FrostedGlass(
        borderColor: Colors.greenAccent.withOpacity(0.4),
        backgroundColor: Colors.greenAccent.withOpacity(0.07),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerRow(),
            const Divider(thickness: 0.8, color: Colors.white24),
            _buildTableSection([
              _tableRow("SHIFT", fmtP.shiftMins, fmtP.shiftPay),
              _tableRow("WORKED", fmtP.clockMins, fmtP.clockPay),
            ]),
            const Divider(thickness: 0.6, color: Colors.white24),
            _buildTableSection([
              _tableRow(
                "LATE IN",
                fmtP.lateInMins,
                fmtP.lateInPay,
                value2Dr: true,
              ),
              _tableRow(
                "LATE OUT",
                fmtP.lateOutMins,
                fmtP.lateOutPay,
                textLineThroug: approvedLateOut,
              ),
              if (approvedLateOut)
                _tableRow(
                    "", fmtP.approvedLateOutMins!, fmtP.approvedLateOutPay!),
            ]),
            _buildTableSection([
              _tableRow(
                "EARLY IN",
                fmtP.earlyInMins,
                fmtP.earlyInPay,
                textLineThroug: approvedEarlyIn,
              ),
              if (approvedEarlyIn)
                _tableRow(
                  "EARLY IN",
                  fmtP.approvedEarlyInMins!,
                  fmtP.approvedEarlyInPay!,
                ),
              _tableRow(
                "EARLY OUT",
                fmtP.earlyOutMins,
                fmtP.earlyOutPay,
                value2Dr: true,
              ),
            ]),
            const Divider(thickness: 0.6, color: Colors.white24),
            _buildTableSection([
              _tableRow("EXTRA HOURS", fmtP.extraTimeMin, fmtP.extraTimePay),
              _tableRow("MAIN TOTAL", "", fmtInr(fmtP.total)),
            ]),
            const Divider(thickness: 1, color: Colors.white54),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _totalRow(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          fmtP.monthDay,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        PayrollStateChip(
          text: "Present",
          backGroundColor: Colors.greenAccent.shade400,
          textColor: Colors.black,
        ),
      ],
    );
  }

  Widget _buildTableSection(List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _tableRow(
    String label,
    String value,
    String value2, {
    bool textLineThroug = false,
    bool value2Dr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Label column: left-aligned
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white60,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.left, // ensures label sticks left
            ),
          ),

          // First value column: center-aligned
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                value,

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration:
                      textLineThroug ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.center, // fallback
              ),
            ),
          ),

          // Second value column: right-aligned
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value2Dr ? "(-) $value2" : value2,
                style: TextStyle(
                  fontSize: 13,
                  color: value2Dr ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration:
                      textLineThroug ? TextDecoration.lineThrough : null,
                ),
                textAlign: TextAlign.right, // fallback
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "NET TOTAL",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          fmtInr(fmtP.netTotal),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PayrollSpecialCard extends StatelessWidget {
  const PayrollSpecialCard({
    super.key,
    required this.color,
    required this.fmtPs,
    required this.chipColor,
  });

  final Color color;
  final FormattedPayrollSpecial fmtPs;
  final Color? chipColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FrostedGlass(
          borderColor: color.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          backgroundColor: color.withOpacity(0.08),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmtPs.monthDay, style: monthDayStyle),
                  PayrollStateChip(
                    text: fmtPs.message,
                    backGroundColor: color,
                    textColor: chipColor,
                  ),
                ],
              ),
              const Divider(),
              Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      if (fmtPs.type == "Paid") _buildTableHeader("Paid Leave"),
                      _buildTableHeader("Extra Hours"),
                      _buildTableHeader("Amount"),
                    ],
                  ),
                  TableRow(
                    children: [
                      if (fmtPs.type == "Paid") _buildTableCell(fmtPs.pay),
                      _buildTableCell(fmtPs.extratimeMin),
                      _buildTableCell(fmtPs.extratimePay),
                    ],
                  ),
                ],
              ),
              const Divider(),
              _buildPayrollRow("Total", fmtInr(fmtPs.total), isBold: true)
            ],
          )),
    );
  }
}

class PayrollStateChip extends StatelessWidget {
  const PayrollStateChip({
    super.key,
    required this.text,
    required this.backGroundColor,
    this.textColor = Colors.white,
  });

  final String text;
  final Color? textColor;
  final Color backGroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 4,
      label: Text(
        text,
        style: TextStyle(
          color: textColor, // Changed to white for better contrast
          fontSize: 14,
          fontWeight: FontWeight.w500, // Added slight boldness
        ),
      ),
      backgroundColor: backGroundColor,
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6), // Added nicer padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // More pill-like look
      ),
    );
  }
}

class PayrollTotalCard extends StatelessWidget {
  const PayrollTotalCard({super.key, required this.total});
  final PayrollTotal total;
  @override
  Widget build(BuildContext context) {
    return FrostedGlass(
      backgroundColor: Colors.blue.withOpacity(0.1),
      borderColor: Colors.blueAccent.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Totals",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1, color: Colors.white54),
            const SizedBox(height: 10),
            _buildPayrollRow("Base", fmtInr(total.baseEarned)),
            _buildPayrollRow("Overtime", fmtInr(total.overtimeEarned)),
            _buildPayrollRow("Extra Time", fmtInr(total.extratimeEarned)),
            _buildPayrollRow("Paid Leaves", fmtInr(total.paidLeave)),
            const Divider(thickness: 1, color: Colors.white54),
            _buildPayrollRow("Total", fmtInr(total.total), isBold: true),
          ],
        ),
      ),
    );
  } // Small helper for header styling
}

Widget _buildTableHeader(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: const TextStyle(
      color: Colors.white70,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
}

// Small helper for cell styling
Widget _buildTableCell(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
    ),
  );
}

Widget _buildPayrollRow(String label, String value, {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
