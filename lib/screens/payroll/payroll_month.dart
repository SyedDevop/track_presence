import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/main.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/payroll_model.dart';
import 'package:vcare_attendance/services/state.dart';
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
  PayrollRaw? payrolls;
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
        setState(() {
          payrolls = res;
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
    List<DataRow> payrollRows() {
      final payPerMin = payrolls?.info.salaryPerMinute ?? 0;
      return payrolls?.payrolls
              ?.map((e) => DataRow(cells: [
                    DataCell(Text(e.dateDay)),
                    DataCell(Text("${e.attendance.shiftMin}")),
                    DataCell(Text("${e.attendance.shiftMin * payPerMin}")),
                    DataCell(Text("${e.attendance.workedMin}")),
                    DataCell(Text("${e.attendance.workedMin * payPerMin}")),
                    DataCell(Text("${e.attendance.lateInLohMin}")),
                    DataCell(Text("${e.attendance.lateInLohMin * payPerMin}")),
                    DataCell(Text("${e.attendance.lateOutOtMin}")),
                    DataCell(Text("${e.attendance.lateOutOtMin * payPerMin}")),
                    DataCell(Text("${e.attendance.earlyInOtMin}")),
                    DataCell(Text("${e.attendance.earlyInOtMin * payPerMin}")),
                    DataCell(Text("${e.attendance.earlyOutLohMin}")),
                    DataCell(
                        Text("${e.attendance.earlyOutLohMin * payPerMin}")),
                    const DataCell(Text("00.000")),
                    DataCell(Text("${e.extratimeMin}")),
                    DataCell(Text("${e.extratimeMin * payPerMin}")),
                    const DataCell(Text("000.0000")),
                  ]))
              .toList() ??
          [];
    }

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
                    child: InteractiveViewer(
                      constrained: false,
                      child: DataTable(columns: const [
                        DataColumn(label: Text("Date")),
                        DataColumn(label: Text("Shift Hours")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Worked Hours ")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Late In")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Late Out ")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Early In")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Early Out ")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Main Total")),
                        DataColumn(label: Text("Extra Hours ")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Total")),
                      ], rows: [
                        ...payrollRows(),
                        const DataRow(cells: [
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("Total")),
                          DataCell(Text("0000:00")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("0000:0")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("")),
                          DataCell(Text("5656565")),
                          DataCell(Text("")),
                          DataCell(Text("45464")),
                          DataCell(Text("45646")),
                          //
                        ]),
                      ]),
                    ),
                  ),
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
