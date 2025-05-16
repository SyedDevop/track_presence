import 'package:dropdown_search/dropdown_search.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/main.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/loan_model.dart';
import 'package:vcare_attendance/models/payslip_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';
import 'package:vcare_attendance/utils/utils.dart';
import 'package:vcare_attendance/widgets/chart/piechart.dart';
import 'package:vcare_attendance/widgets/widget.dart';

class PayrollMonthScreen extends StatefulWidget {
  const PayrollMonthScreen({super.key});

  @override
  State<PayrollMonthScreen> createState() => _PayrollMonthScreenState();
}

class _PayrollMonthScreenState extends State<PayrollMonthScreen> {
  final apil = Api.loan;
  final apip = Api.payslip;
  bool _loading = false;

  String _selectedPeriod = "";

  List<LoanPayment> loanPayment = [];
  List<LoanPayment> loanCr = [];
  List<LoanPayment> loanDr = [];
  Payslip? payslip;
  final profile = getIt<AppState>().profile;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedYear = DateTime.now().year;
  final List<int> years = List.generate(
    10,
    (index) => DateTime.now().year - 1 + index,
  );
  String selectedMonth = "";

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
      final res = await apip.fetchPayslipsByMonthAndYear(
        userId,
        month,
        year,
      );
      if (res != null) {
        final loanRes = await apil.getLoanPaymentFromPayrollId(userId, res.id);
        loanCr = loanRes.where((loan) => loan.credited).toList();
        loanDr = loanRes.where((loan) => !loan.credited).toList();
        setState(() {
          payslip = res;
          loanPayment = loanRes;
        });
      }
    } catch (e) {
      setState(() {
        payslip = null;
        loanPayment = [];
        loanCr = [];
        loanDr = [];
      });
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
                  if (payslip != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              _selectedPeriod,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            PayslipMonthBody(
                              payslip: payslip!,
                              loanCr: loanCr,
                              loanDr: loanDr,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _handleDownload,
                              icon: const Icon(Icons.download_rounded),
                              label: const Text('Download Payslip'),
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    )
                  else if (_selectedPeriod.isNotEmpty && payslip == null)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No Payslip Found For the select a month and year \"$_selectedPeriod\"",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Please select a month and year to view your payroll details.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
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

  Future<void> _handleDownload() async {
    setState(() => _loading = true);
    try {
      final resMessage = await apip.downloadPayslip(payslip!.id);
      if (resMessage != null) {
        snackbarSuccess(context, message: resMessage);
      }
    } catch (e) {
      if (e is String) {
        snackbarError(context, message: e);
      } else {
        print("[Error]: #downloadButton catch:error $e");
      }
    } finally {
      setState(() => _loading = false);
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

class PayslipBreakDown extends StatelessWidget {
  const PayslipBreakDown({
    super.key,
    required this.payslip,
    required this.loanCr,
    required this.loanDr,
    required this.earnings,
    required this.deductions,
  });

  final Payslip? payslip;
  final List<LoanPayment> loanCr;
  final List<LoanPayment> loanDr;
  final double earnings;
  final double deductions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.greenAccent.withOpacity(0.2),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Earnings",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      Text(
                        fmtInr(earnings),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  children: [
                    ReportSheetRow(
                      leadingText: "Base Salary",
                      trailingText: fmtInr(payslip?.daysSalary),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                    ...payslip?.allowances.entries.map((entry) {
                          return ReportSheetRow(
                            leadingText: entry.key,
                            trailingText: fmtInr(entry.value),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                          );
                        }) ??
                        [],
                    ...loanCr.map((loan) {
                      return ReportSheetRow(
                        leadingText: "Loan: ${loan.loanType}",
                        trailingText: fmtInr(loan.amountPaid),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.redAccent.withOpacity(0.2),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Deductions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      Text(
                        fmtInr(deductions),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    ...payslip?.deductions.entries.map((entry) {
                          return ReportSheetRow(
                            leadingText: entry.key,
                            trailingText: fmtInr(entry.value),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                          );
                        }) ??
                        [],
                    ...loanDr.map((loan) {
                      return ReportSheetRow(
                        leadingText: "Loan: ${loan.loanType}",
                        trailingText: fmtInr(loan.amountPaid),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PayslipMonthBody extends StatelessWidget {
  const PayslipMonthBody({
    super.key,
    required this.payslip,
    required this.loanCr,
    required this.loanDr,
  });

  final Payslip payslip;
  final List<LoanPayment> loanCr;
  final List<LoanPayment> loanDr;

  double get totalLoanCr =>
      loanCr.fold(0.0, (sum, cur) => sum + cur.amountPaid);
  double get totalLoanDr =>
      loanDr.fold(0.0, (sum, cur) => sum + cur.amountPaid);

  @override
  Widget build(BuildContext context) {
    final earnings = payslip.daysSalary + payslip.totalAllowances + totalLoanCr;
    final deductions = payslip.totalDeductions + totalLoanDr;
    return Column(
      children: [
        PayslipSummery(
          payslip: payslip,
          earnings: earnings,
          deductions: deductions,
        ),
        PayslipBreakDown(
          payslip: payslip,
          loanCr: loanCr,
          loanDr: loanDr,
          earnings: earnings,
          deductions: deductions,
        ),
      ],
    );
  }
}

class PayslipSummery extends StatelessWidget {
  const PayslipSummery({
    super.key,
    required this.payslip,
    required this.earnings,
    required this.deductions,
  });

  final Payslip? payslip;
  final double earnings;
  final double deductions;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: PieChart(PieChartData(
                    sectionsSpace: 5,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.greenAccent,
                        value: earnings - deductions,
                        radius: 30,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: Colors.redAccent,
                        value: deductions,
                        radius: 30,
                        showTitle: false,
                      ),
                    ])),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoRowWidget(
                    label: "Earned Salary",
                    color: Colors.greenAccent,
                    value: fmtInr(earnings - deductions),
                  ),
                  InfoRowWidget(
                    label: "Deducted Salary",
                    color: Colors.redAccent,
                    value: fmtInr(deductions),
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Text("Total Gross Pay: ${fmtInr(earnings)}"),
          ),
          const Divider(),
          Container(
            color: Colors.yellowAccent.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Paid Day: ${payslip!.totalDays}    |    LOP Day: ${payslip!.lostDays}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
