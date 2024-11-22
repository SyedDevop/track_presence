import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final _stateSR = getIt<AppState>();
  Profile? _profile;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd h:mm a");
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
    await _stateSR.initProfile("vch0000");
    _profile = _stateSR.profile;
  }

  final _monthDP = GlobalKey<DropdownSearchState<String>>();
  final _yearDP = GlobalKey<DropdownSearchState<int>>();
  final _formKey = GlobalKey<FormState>();

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
                  const SizedBox(height: 15),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _summeryCard(context)),
                        if (report != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Attendance",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
                        if (report != null)
                          SliverList.builder(
                            itemCount: report?.attendance.length,
                            itemBuilder: (context, index) {
                              final atten = report!.attendance;
                              final item = atten[index];
                              final statusColor = item.status == "1"
                                  ? Colors.greenAccent
                                  : Colors.redAccent;
                              return Card(
                                elevation: 2.5,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        statusColor.withOpacity(0.2),
                                    child: Icon(Icons.calendar_today_rounded,
                                        color: statusColor),
                                  ),
                                  title: Text(item.date,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    "In: ${item.inTime} -/- Out: ${item.outTime ?? "--:--:--"}\nExtra Hour Count: ${item.extraHours.length}",
                                    maxLines: 2,
                                  ),
                                  isThreeLine: true,
                                  trailing: const Icon(Icons.read_more_rounded),
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        if (report != null && extraHoursKeys != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    "Extra Hours",
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
                        if (report != null && extraHoursKeys != null)
                          SliverList.builder(
                            itemCount: extraHoursKeys!.length,
                            itemBuilder: (context, index) {
                              final atKey = extraHoursKeys![index];
                              final atten = report!.extraHours[atKey];
                              const statusColor = Colors.greenAccent;
                              return Card(
                                elevation: 2.5,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        statusColor.withOpacity(0.2),
                                    child: const Icon(
                                        Icons.calendar_today_rounded,
                                        color: statusColor),
                                  ),
                                  title: Text(atKey,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                      "Extra Hour Count: ${atten?.length ?? 0}"),
                                  trailing: const Icon(Icons.read_more_rounded),
                                  onTap: () {},
                                ),
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
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _loading = true;
            });
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
            setState(() {
              _loading = false;
            });
          }
        },
        icon: const Icon(Icons.manage_search_rounded),
        iconSize: 32,
        style: IconButton.styleFrom(
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(15),
        ),
      ),
    );
  }

  void calculateTimes(Report? rep) {
    if (rep == null) return;

    Duration calDiff(String date, String inTime, String? outTime) {
      if (outTime == null) return Duration.zero;
      final inT = dateFormat.parse("$date $inTime".toUpperCase());
      final outT = dateFormat.parse("$date $outTime".toUpperCase());
      return outT.difference(inT);
    }

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

  Card _summeryCard(BuildContext context) {
    return Card(
      elevation: 4,
      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary", style: TextStyle(fontSize: 16)),
            const Divider(),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _numberBlock("Present", report?.info.presentCount ?? "0",
                    Colors.greenAccent),
                _numberBlock("Absent", report?.info.absentCount ?? "0",
                    Colors.redAccent),
                _numberBlock("Total Entry", "$toEntry", Colors.yellowAccent),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.spaceAround,
                spacing: 15,
                children: [
                  _timeBlock(
                      "Total Shift Hour",
                      "${toShiftTime.inHours}hr ${toShiftTime.inMinutes % 60}min",
                      Colors.tealAccent),
                  _timeBlock(
                      "Total Extra Hour",
                      "${toExtraTime.inHours}hr ${toExtraTime.inMinutes % 60}min",
                      Colors.blueAccent),
                  _timeBlock(
                      "Total Worked Hour",
                      "${toWorkTime.inHours}hr ${(toWorkTime.inMinutes % 60)}min",
                      Colors.cyanAccent),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _numberBlock(String title, String value, Color color) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w200)),
        ],
      );
  Widget _timeBlock(String title, String value, Color color) => Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, color: color)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w200)),
        ],
      );
}
