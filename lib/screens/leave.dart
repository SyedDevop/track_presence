import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/leave_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';
import 'package:vcare_attendance/utils/utils.dart';

import 'package:vcare_attendance/widgets/widget.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final apiL = Api.leave;
  bool _loading = false;

  List<Leave> leaves = [];
  final profile = getIt<AppState>().profile;

  PickerDateRange? range;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final _reasonCT = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    super.dispose();
    _reasonCT.dispose();
  }

  Future<void> _fetchLeaves() async {
    final leav = await apiL.getLeaves(profile?.userId ?? " ");
    setState(() => leaves = leav);
  }

  Future<void> _start() async {
    _loading = true;
    await _fetchLeaves();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(title: const Text("Leaves")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 1),
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _fetchLeaves,
                child: ListView.builder(
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    final item = leaves[index];
                    return LeaveCard(leave: item);
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showDateSheet(context);

          scaffoldKey.currentState!
              .showBottomSheet((context) => _showFormSheet());
        },
        child: const Icon(Icons.library_add_rounded),
      ),
    );
  }

  Future<void> _submit() async {
    if (mounted) context.pop();
    if (profile == null) {
      snackbarError(context, message: "User profile is not Set 😭");
      return;
    }

    if (range == null || range?.startDate == null || range?.endDate == null) {
      snackbarError(context, message: "Dates not selected for leave 😭");
      return;
    }
    if (_formKey.currentState!.validate()) {
      snackbarNotefy(context, message: 'Applying for leave..🔥🔥🔥..');
      try {
        final fDate = dateFmt.format(range!.startDate!);
        final tDate = dateFmt.format(range!.endDate!);
        await apiL.postLeaves(
          userId: profile!.userId,
          name: profile!.name,
          fromDate: fDate,
          toDate: tDate,
          reason: _reasonCT.text,
          department: profile!.department ?? " None ",
        );

        await _fetchLeaves();
        snackbarSuccess(context, message: "Leave applied successful..🎉🎉🎉..");
      } on ApiException catch (e) {
        snackbarError(context, message: "${e.message}  😭");
      } catch (e) {
        print("[Error]: Api Posting Leave error :: $e");
      }
    }
  }

  Widget _showFormSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Apply For Leave",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(),
          const SizedBox(height: 25),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _reasonCT,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: "Reason",
                    prefixIcon: Icon(Icons.psychology_alt_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Reason  is required for Leave";
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          FilledButton(
            onPressed: _submit,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 50,
              ),
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
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
          selectionMode: DateRangePickerSelectionMode.range,
          showTodayButton: true,
          showActionButtons: true,
          enableMultiView: true,
          enablePastDates: false,
          onCancel: () => context.pop(),
          onSubmit: (Object? value) {
            if (mounted) context.pop();
            if (value is PickerDateRange) {
              setState(() => range = value);
            }
          },
        ),
      ),
    );
  }
}

class LeaveCard extends StatelessWidget {
  const LeaveCard({super.key, required this.leave});
  final Leave leave;
  @override
  Widget build(BuildContext context) {
    return AtCard1(
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: leave.statusColor?.withOpacity(0.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              leave.status,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: leave.statusColor,
              ),
            ),
          ),
        ),
      ),
      children: [
        ReportSheetRow(
          leadingIcon: Icons.work_rounded,
          leadingText: "From:",
          trailingText: leave.startDate,
        ),
        ReportSheetRow(
          leadingIcon: Icons.work_rounded,
          leadingText: "To:",
          trailingText: leave.endDate,
        ),
        ReportSheetRow(
          leadingIcon: Icons.work_rounded,
          leadingText: "Reason:",
          trailingText: leave.reason,
        ),
      ],
    );
  }
}
