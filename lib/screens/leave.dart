import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/holidays.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/leave_model.dart';
import 'package:vcare_attendance/services/service.dart';
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
  final _appSr = getIt<AppStore>();
  String _userId = "";
  PickerDateRange? range;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final _reasonCT = TextEditingController(text: '');
  final _formKey = GlobalKey<FormState>();
  final _leaveTypeKey = GlobalKey<DropdownSearchState<String>>();
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
    try {
      final leav = await apiL.getLeaves(_userId);
      setState(() => leaves = leav);
    } catch (e) {
      setState(() => leaves = []);
      print("[Error] Fetching Leaves: $e");
    }
  }

  Future<void> _start() async {
    _loading = true;
    _userId = _appSr.token.sub;
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
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 1),
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
    if (range == null || range?.startDate == null || range?.endDate == null) {
      snackbarError(context, message: "Dates not selected for leave 😭");
      if (mounted) context.pop();
      return;
    }
    if (_formKey.currentState!.validate()) {
      snackbarNotefy(context, message: 'Applying for leave..🔥🔥🔥..');
      try {
        final fDate = dateFmt.format(range!.startDate!);
        final tDate = dateFmt.format(range!.endDate!);
        await apiL.postLeaves(
          userId: _userId,
          name: _appSr.token.name,
          fromDate: fDate,
          toDate: tDate,
          reason: _reasonCT.text,
          leaveType: _leaveTypeKey.currentState?.getSelectedItem as String,
          department: _appSr.token.department,
        );

        await _fetchLeaves();
        snackbarSuccess(context, message: "Leave applied successful..🎉🎉🎉..");
      } on DioException catch (e) {
        snackbarError(context, message: "${e.message}  😭");
      } catch (e) {
        print("[Error]: Api Posting Leave error :: $e");
      } finally {
        if (mounted) context.pop();
      }
    }
  }

  Widget _showFormSheet() {
    final theme = Theme.of(scaffoldKey.currentContext!);
    final radius = 16.0;

    return Material(
      // Use Material so ink, elevation & theme colors work correctly.
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          // card-like container with rounded top corners (for bottom sheet)
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withAlpha(30),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom:
                MediaQuery.of(scaffoldKey.currentContext!).viewInsets.bottom +
                    20,
          ),
          child: SingleChildScrollView(
            // prevents overflow when keyboard opens
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // draggable handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                Text(
                  "Apply For Leave",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),
                Divider(color: theme.dividerColor, height: 1),
                const SizedBox(height: 18),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _reasonCT,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: "Reason",
                          prefixIcon: const Icon(Icons.psychology_alt_rounded),
                          filled: true,
                          fillColor: theme.inputDecorationTheme.fillColor ??
                              theme.colorScheme.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Reason is required for leave";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // DropdownSearch: use the provided list directly (not the two-arg form)
                      DropdownSearch<String>(
                        key: _leaveTypeKey,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? i) {
                          if (i == null || i.trim().isEmpty) {
                            return 'Leave Type is required';
                          }
                          return null;
                        },
                        items: (_, __) => kHolidays, // assume List<String>
                        selectedItem: null,
                        popupProps: PopupProps.menu(
                          fit: FlexFit.loose,
                          showSelectedItems: true,
                          showSearchBox: true,
                          menuProps: MenuProps(
                            // prefer theme instead of hard-coded color
                            backgroundColor: theme.dialogBackgroundColor,
                            elevation: 6,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(8),
                              right: Radius.circular(8),
                            ),
                          ),
                        ),
                        compareFn: (item1, item2) => item1 == item2,
                        decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                            labelText: "Select a Leave Type",
                            hintText: "leave type...",
                            filled: true,
                            fillColor: theme.inputDecorationTheme.fillColor ??
                                theme.colorScheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(scaffoldKey.currentContext!).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
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
      builder: (context) => SafeArea(
        child: Container(
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
            color: leave.statusColor?.withValues(alpha: 0.2),
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
