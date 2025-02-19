import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/attendance_model.dart';
import 'package:vcare_attendance/models/extra_hour_modeal.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/utils/utils.dart';

import 'package:vcare_attendance/widgets/widget.dart';

/// [AtReportScreen] Attendance Report Screen.
class AtReportScreen extends StatefulWidget {
  const AtReportScreen({super.key});

  @override
  State<AtReportScreen> createState() => _AtReportScreenState();
}

typedef Empolye = (String, String);

class _AtReportScreenState extends State<AtReportScreen> {
  final _attendanceApi = Api.attendance;

  final _stateSR = getIt<AppState>();
  Profile? _profile;

  int currYear = DateTime.now().year;
  int yearLinit = 10;
  int year = DateTime.now().year;
  String month = months[DateTime.now().month - 1];

  Report? report;
  List<String>? extraHoursKeys;

  /// Total Entrys
  int toEntry = 0;
  int presentCount = 0;
  int absentCount = 0;
  int overtimeCount = 0;
  int extraDayCount = 0;
  int leaveCount = 0;
  int holidayCount = 0;

  Duration toShiftTime = Duration.zero;
  Duration toExtraTime = Duration.zero;
  Duration toWorkTime = Duration.zero;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    _profile = _stateSR.profile;
  }

  final _monthDP = GlobalKey<DropdownSearchState<String>>();
  final _yearDP = GlobalKey<DropdownSearchState<int>>();
  final _formKey = GlobalKey<FormState>();

  final AnimationStyle _animationStyle = AnimationStyle(
    duration: const Duration(seconds: 1),
    reverseDuration: const Duration(seconds: 1),
    curve: Curves.fastLinearToSlowEaseIn,
  );
  void _resetSummery() {
    toEntry = 0;
    presentCount = 0;
    absentCount = 0;
    overtimeCount = 0;
    extraDayCount = 0;
    leaveCount = 0;
    holidayCount = 0;
    toShiftTime = Duration.zero;
    toExtraTime = Duration.zero;
    toWorkTime = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summery')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      ],
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                            child: ReportHeader("Summery")),
                        SliverToBoxAdapter(child: _reportSummery(context)),
                        const SliverToBoxAdapter(
                            child: ReportHeader("Attendance")),
                        SliverList.builder(
                          itemCount: report?.data.length,
                          itemBuilder: (context, index) {
                            if (report == null) return null;
                            final data = report!.data[index];
                            final atten = data.attendance;
                            final isShift = data.shift;
                            final isLeave = data.leaveStatus == "Approved";
                            final extraHour = data.extraHour;
                            overtimeCount += extraHour.length;
                            if (atten != null) {
                              presentCount += 1;
                              return AttendanceCard(
                                data.date,
                                statusColor: Colors.greenAccent,
                                inTime: atten.inTime,
                                outTime: atten.outTime ?? "--:--:--",
                                extraHourCount: extraHour.length,
                                onTap: () => _showAtFullReport(
                                    context, atten, extraHour),
                              );
                            } else if (extraHour.isNotEmpty) {
                              extraDayCount += 1;
                              return ExtraHourCard(
                                statusColor: Colors.greenAccent,
                                title: data.date,
                                count: extraHour.length,
                                onTap: () => _showExFullReport(
                                    context, data.date, extraHour),
                              );
                            } else if (isShift == true && isLeave == false) {
                              absentCount += 1;
                              return AbsentCard(
                                data.date,
                                onTap: () => (),
                              );
                            } else if (isLeave == true) {
                              leaveCount += 1;
                              return LeaveCard(data.date);
                            } else if (isShift == false && isLeave == false) {
                              holidayCount += 1;
                              return HolidayCard(data.date);
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: IconButton.filled(
        onPressed: _fetchReport,
        icon: const Icon(Icons.manage_search_rounded),
        iconSize: 32,
        style: IconButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  Container _reportSummery(BuildContext context) => Container(
        height: 75,
        color: Theme.of(context).primaryColorDark.withAlpha(30),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _summeryRow(),
        ),
      );

  void _fetchReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      try {
        _resetSummery();
        final emp = "${_profile?.name ?? " "}-${_profile?.userId ?? " "}";
        final rep = await _attendanceApi.getReport(emp, month, year);
        setState(() => report = rep);
        calculateTimes(rep);
        toWorkTime = toExtraTime + toShiftTime;
      } catch (e) {
        print("[Error] in _fetchReport :: $e");
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showAtFullReport(
    BuildContext context,
    Attendance attendance,
    List<ExtraHour> extraHour,
  ) {
    showModalBottomSheet(
      context: context,
      sheetAnimationStyle: _animationStyle,
      elevation: 4,
      builder: (BuildContext context) =>
          FullAttendancesReport(attendance: attendance, extraHours: extraHour),
    );
  }

  void _showExFullReport(
      BuildContext context, String extraHourDate, List<ExtraHour> extraHour) {
    showModalBottomSheet(
      context: context,
      sheetAnimationStyle: _animationStyle,
      elevation: 4,
      builder: (BuildContext context) => FullExtraHoursReport(
        extraHourDate: extraHourDate,
        extraHour: extraHour,
      ),
    );
  }

  void calculateTimes(Report? rep) {
    if (rep == null) return;

    for (var data in rep.data) {
      final atten = data.attendance;
      final isShift = data.shift;
      final isLeave = data.leaveStatus == "Approved";
      final extraHour = data.extraHour;

      // Calculate attendance summary
      if (atten != null) {
        presentCount += 1;
        toEntry += extraHour.length + 1;
        toShiftTime += calDiff(atten.inTime, atten.outTime);
      } else if (extraHour.isNotEmpty) {
        toEntry += extraHour.length;
        extraDayCount += 1;
      } else if (isShift == true && isLeave == false) {
        absentCount += 1;
      } else if (isLeave == true) {
        leaveCount += 1;
      } else if (isShift == false && isLeave == false) {
        holidayCount += 1;
      }
      for (var exh in data.extraHour) {
        toExtraTime += calDiff(exh.inTime, exh.outTime);
      }
    }
  }

  List<Widget> _summeryRow() {
    return [
      numberBlock("Present", "$presentCount", Colors.greenAccent),
      numberBlock("Absent", "$absentCount", Colors.redAccent),
      numberBlock("Leave", "$leaveCount", Colors.blueAccent),
      numberBlock("Holiday", "$holidayCount", Colors.yellowAccent),
      numberBlock("Total Entry", "$toEntry", Colors.orangeAccent),
      timeBlock("Total Shift Hour", durationToHrMin(toShiftTime), Colors.teal),
      timeBlock("Total Extra Hour", durationToHrMin(toExtraTime), Colors.blue),
      timeBlock("Total Worked Hour", durationToHrMin(toWorkTime), Colors.cyan),
    ];
  }
}
