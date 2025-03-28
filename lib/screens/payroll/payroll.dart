import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/main.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/loan_model.dart';
import 'package:vcare_attendance/models/payslip_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/widgets/dropdown/at_dropdown.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final apil = Api.loan;
  final apip = Api.payslip;
  bool isLoading = false;

  List<LoanPayemt> loanPayemt = [];
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
      isLoading = true;
    });
    try {
      final response = await apip.fetchPayslipsByMonthAndYear(
        userId,
        month,
        year,
      );
      if (response != null) {
        final res = await apil.getLoanPaymentFromPayrollId(userId, response.id);
        setState(() {
          payslip = response;
          loanPayemt = res;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
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
                        items: (f, cs) =>
                            List.generate(yearLinit, (i) => currYear - i),
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
            ),
            const Expanded(
              child: Center(
                child: Text('Payroll Screen'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            // Perform action with selected month and year
            print("Selected Month: $month");
            print("Selected Year: $year");
          }
        },
        child: const Icon(Icons.search_rounded),
      ),
    );
  }
}
