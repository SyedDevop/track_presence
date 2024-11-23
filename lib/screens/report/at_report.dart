import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/services/state.dart';
import 'package:vcare_attendance/widgets/dropdown/dropdown.dart';
import 'package:vcare_attendance/widgets/report/report_widget.dart';

/// [AtReportScreen] Attendance Report Screen.
class AtReportScreen extends StatefulWidget {
  const AtReportScreen({super.key});

  @override
  State<AtReportScreen> createState() => _AtReportScreenState();
}

typedef Empolye = (String, String);

class _AtReportScreenState extends State<AtReportScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
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
                        const SliverToBoxAdapter(child: RpoerHeader("Summery")),
                        SliverToBoxAdapter(child: _reportSummery(context)),
                        const SliverToBoxAdapter(
                            child: RpoerHeader("Attendance")),
                        SliverList.builder(
                          itemCount: report?.attendance.length,
                          itemBuilder: (context, index) {
                            if (report == null) return null;
                            final atten = report!.attendance;
                            final item = atten[index];
                            final statusColor = item.status == "1"
                                ? Colors.greenAccent
                                : Colors.redAccent;
                            return AttendanceCard(
                              item.date1,
                              statusColor: statusColor,
                              inTime: item.inTime,
                              outTime: item.outTime ?? "--:--:--",
                              extraHourCount: item.extraHours.length,
                              onTap: () => _showAtFullReport(context, item),
                            );
                          },
                        ),
                        const SliverToBoxAdapter(
                            child: RpoerHeader("Extra Hours")),
                        SliverList.builder(
                          itemCount: extraHoursKeys?.length,
                          itemBuilder: (context, index) {
                            if (report == null && extraHoursKeys == null) {
                              return null;
                            }
                            final atKey = extraHoursKeys![index];
                            final atten = report!.extraHours[atKey]!;
                            const statusColor = Colors.greenAccent;
                            return ExtraHourCard(
                              statusColor: statusColor,
                              title: atKey,
                              count: atten.length,
                              onTap: () =>
                                  _showExFullReport(context, atKey, atten),
                            );
                          },
                        )
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
        toExtraTime = Duration.zero;
        toShiftTime = Duration.zero;
        toWorkTime = Duration.zero;
        final emp = "${_profile?.name ?? " "}-${_profile?.userId ?? " "}";
        final rep = await Api.getReport(emp, month, year);
        setState(() {
          report = rep;
          extraHoursKeys = rep?.extraHours.keys.toList();
        });
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
    AttendanceReport attendance,
  ) {
    showModalBottomSheet(
      context: context,
      sheetAnimationStyle: _animationStyle,
      elevation: 4,
      builder: (BuildContext context) =>
          FullAttendancesReport(item: attendance),
    );
  }

  void _showExFullReport(BuildContext context, String extraHourDate,
      List<ExtraHourReport> extraHour) {
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
    for (var at in rep.attendance) {
      for (var e in at.extraHours) {
        toExtraTime += calDiff(e.date, e.inTime, e.outTime);
      }

      if (at.outTime == null || at.status == "0") continue;
      toShiftTime += calDiff(at.date, at.inTime, at.outTime);
    }
    rep.extraHours.forEach((_, v) {
      for (var e in v) {
        toExtraTime += calDiff(e.date, e.inTime, e.outTime);
      }
    });
  }

  List<Widget> _summeryRow() {
    return [
      numberBlock(
          "Present", report?.info.presentCount ?? "0", Colors.greenAccent),
      numberBlock("Absent", report?.info.absentCount ?? "0", Colors.redAccent),
      numberBlock("Total Entry", "$toEntry", Colors.yellowAccent),
      timeBlock(
          "Total Shift Hour", durationToHrMin(toShiftTime), Colors.tealAccent),
      timeBlock(
          "Total Extra Hour", durationToHrMin(toExtraTime), Colors.blueAccent),
      timeBlock(
          "Total Worked Hour", durationToHrMin(toWorkTime), Colors.cyanAccent),
    ];
  }
}
