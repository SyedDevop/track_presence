import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/widgets/dropdown/dropdown.dart';

const List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

typedef Empolye = (String, String);

class _ReportScreenState extends State<ReportScreen> {
// ----------------------------------------------------
  int currYear = DateTime.now().year;
  int yearLinit = 10;
  final _stateSR = getIt<AppState>();
  Profile? _profile;

  int year = DateTime.now().year;
  String month = months[DateTime.now().month - 1];

  Report? report;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _stateSR.initProfile("vch0000");
    _profile = _stateSR.profile;
  }

  final _monthDP = GlobalKey<DropdownSearchState<String>>();
  final _yearDP = GlobalKey<DropdownSearchState<int>>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AtDropdown<String>(
                    dropdownKey: _monthDP,
                    selectedItem: month,
                    labelText: "Select Month",
                    hintText: "select a month.",
                    validationErrorText: "month is required.",
                    items: (f, cs) => months,
                    onChanged: (p0) {
                      if (p0 != null) {
                        month = p0;
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  AtDropdown<int>(
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
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final emp =
                            "${_profile?.name ?? " "}-${_profile?.userId ?? " "}";
                        final rep = await Api.getReport(emp, month, year);
                        setState(() {
                          report = rep;
                        });
                      }
                    },
                    icon: const Icon(Icons.search_rounded),
                    label: const Text("Fetch Attendance"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
