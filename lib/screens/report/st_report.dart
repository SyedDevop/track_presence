import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/shift_report_modeal.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/widgets/report/report_widget.dart';

/// [StReportScreen] is Shifts Report screen
class StReportScreen extends StatefulWidget {
  const StReportScreen({super.key});

  @override
  State<StReportScreen> createState() => _StReportScreenState();
}

final DateFormat dateFmt = DateFormat('dd/MM/yyyy');

class _StReportScreenState extends State<StReportScreen> {
  final _stateSR = getIt<AppState>();
  Profile? _profile;

  bool _loading = false;
  PickerDateRange? range;

  ShiftReport? shiftReport;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _profile = _stateSR.profile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shifts Summary")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: shiftReport == null || (shiftReport?.data.isEmpty ?? true)
                  ? const Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No Shifts Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                            height: 10), // Add some spacing between the texts
                        Text(
                          "Please select a date range using the action button below.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center, // Center align the text
                        ),
                      ],
                    ))
                  : ListView.builder(
                      itemCount: shiftReport?.data.length,
                      itemBuilder: (context, index) {
                        if (shiftReport == null) return null;
                        final item = shiftReport!.data[index];
                        return Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    "From: ${item.fromDate} -/- To: ${item.toDate}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryFixed),
                                  ),
                                ),
                                const Divider(),
                                ReportSheetRow(
                                    leadingIcon: Icons.work_rounded,
                                    leadingText: "Shift:",
                                    trailingText: item.shiftTime),
                                ReportSheetRow(
                                    leadingIcon: Icons.help_rounded,
                                    leadingText: "reason:",
                                    trailingText: item.reason),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: IconButton.filled(
        onPressed: () => _showDateRangeSheet(context),
        icon: const Icon(Icons.date_range_rounded),
        iconSize: 32,
        style: IconButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Future<void> _showDateRangeSheet(BuildContext context) async {
    showModalBottomSheet(
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
            selectionMode: DateRangePickerSelectionMode.range,
            showTodayButton: true,
            showActionButtons: true,
            enableMultiView: true,
            onCancel: () => context.pop(),
            onSubmit: (Object? value) {
              if (mounted) context.pop();
              if (value is PickerDateRange) {
                setState(() => range = value);
                _fetchShifts();
              }
            }),
      ),
    );
  }

  Future<void> _fetchShifts() async {
    setState(() => _loading = true);
    if (_profile == null) return;
    if (range == null) return;
    final fromDate = range!.startDate;
    final toDate = range!.endDate;

    if (fromDate == null || toDate == null) return;
    final fdStr = dateFmt.format(fromDate);
    final tdStr = dateFmt.format(toDate);
    final sh = await Api.getShifts(_profile!.userId, fdStr, tdStr);
    if (sh != null) {
      setState(() => shiftReport = sh);
    }

    setState(() => _loading = false);
  }
}
