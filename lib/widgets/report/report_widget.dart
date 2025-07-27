import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:vcare_attendance/models/attendance_model.dart';
import 'package:vcare_attendance/models/extra_hour_modeal.dart';
import 'package:vcare_attendance/models/leave_model.dart';
import 'package:vcare_attendance/utils/utils.dart';

enum ReportType { attendance, extraHour }

class FullExtraHoursReport extends StatelessWidget {
  const FullExtraHoursReport({
    super.key,
    required this.extraHour,
    required this.extraHourDate,
    this.leave,
  });

  final List<ExtraHour> extraHour;
  final String extraHourDate;
  final Leave? leave;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportSheetTitle(date: extraHourDate),
              if (leave != null) genrateLeaves(leave!),
              ...extraHoursHeader(),
              ...genrateExtraHours(extraHour),
            ],
          ),
        ),
      ),
    );
  }
}

Widget genrateLeaves(Leave leave) {
  return Column(
    children: [
      const Divider(),
      const Text("Leaves",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const Divider(),
      ReportSheetRow(
        leadingIcon: Icons.browse_gallery_rounded,
        leadingText: "Time:",
        trailingText: "${leave.startDate} -/- ${leave.endDate}",
      ),
      ReportSheetRow(
        leadingIcon: Icons.move_down_rounded,
        leadingText: "Status:",
        trailingText: leave.status,
      ),
      ReportSheetRow(
        leadingIcon: Icons.help_rounded,
        leadingText: "Reason: ",
        trailingText: leave.reason,
      ),
    ],
  );
}

Iterable<Widget> extraHoursHeader() {
  return const [
    Divider(),
    Text(
      "Extra Hours",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    Divider()
  ];
}

Iterable<Widget> genrateExtraHours(List<ExtraHour> exHr) {
  return exHr.map(
    (e) => Column(
      children: [
        ReportSheetRow(
          leadingIcon: Icons.browse_gallery_rounded,
          leadingText: "Time:",
          trailingText: " ${e.inTime} -/- ${e.outTime ?? '\\--__--/'}",
        ),
        ReportSheetRow(
          leadingIcon: Icons.work_history,
          leadingText: "Working Hours:",
          trailingText: durationToHrMin(calDiff(e.inTime, e.outTime)),
        ),
        ReportSheetRow(
          leadingIcon: Icons.help_rounded,
          leadingText: "Reason: ",
          trailingText: e.reason,
        ),
        const Divider(),
      ],
    ),
  );
}

class FullAttendancesReport extends StatelessWidget {
  const FullAttendancesReport({
    super.key,
    required this.attendance,
    required this.extraHours,
    required this.leave,
  });

  final Attendance attendance;
  final List<ExtraHour> extraHours;
  final Leave? leave;
  @override
  Widget build(BuildContext context) {
    final shiftHours = calDiff(attendance.inTime, attendance.outTime);
    final shiftHoursStr = durationToHrMin(shiftHours);
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportSheetTitle(date: attendance.date),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.update_rounded,
                leadingText: "In Time: ",
                trailingText: attendance.inTime,
              ),
              ReportSheetRow(
                leadingIcon: Icons.history_rounded,
                leadingText: "Out Time:",
                trailingText: attendance.outTime,
              ),
              ReportSheetRow(
                leadingIcon: Icons.work_history,
                leadingText: "Working Hours:",
                trailingText: shiftHoursStr,
              ),
              ReportSheetRow(
                leadingIcon: Icons.hourglass_bottom_rounded,
                leadingText: "Loss Of Hours:",
                trailingText: minToHrMin(attendance.lossOfHours),
              ),
              ReportSheetRow(
                leadingIcon: Icons.alarm_add_rounded,
                leadingText: "Over time:",
                trailingText: minToHrMin(attendance.maintainance),
              ),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.schedule_rounded,
                leadingText: "Shift Timing:",
                trailingText: attendance.shiftTime,
              ),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason:",
                trailingText: attendance.reason,
              ),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason For Late:",
                trailingText: attendance.reasonLate,
              ),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason For Early:",
                trailingText: attendance.reasonEarly,
              ),
              if (leave != null) genrateLeaves(leave!),
              if (extraHours.isNotEmpty) ...extraHoursHeader(),
              ...genrateExtraHours(extraHours),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportSheetRow extends StatelessWidget {
  const ReportSheetRow({
    super.key,
    this.leadingIcon,
    required this.leadingText,
    this.trailingText,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
  });

  final IconData? leadingIcon;
  final String leadingText;
  final String? trailingText;
  final EdgeInsets padding;

  TextStyle _leadTextStyle(BuildContext context) =>
      TextStyle(color: Theme.of(context).colorScheme.secondaryFixed);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leadingIcon == null
              ? Text(leadingText, style: _leadTextStyle(context))
              : Text.rich(TextSpan(children: [
                  WidgetSpan(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      size: 18,
                      leadingIcon,
                      color: Theme.of(context).colorScheme.secondaryFixedDim,
                    ),
                  )),
                  TextSpan(text: leadingText, style: _leadTextStyle(context))
                ])),
          Flexible(
            child: ReadMoreText(
              trailingText ?? "\\--__--/",
              colorClickableText: Theme.of(context).colorScheme.primary,
              trimMode: TrimMode.Length,
              trimLength: 40,
              trimCollapsedText: ' ...',
              trimExpandedText: ' less ...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surfaceTint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReportSheetTitle extends StatelessWidget {
  const ReportSheetTitle({
    super.key,
    required this.date,
  });

  final String date;

  @override
  Widget build(BuildContext context) {
    final titleS = Theme.of(context).textTheme.titleLarge;
    final pColor = Theme.of(context).colorScheme.secondaryFixedDim;
    return RichText(
      text: TextSpan(
        text: "Report For: ",
        style: titleS,
        children: [
          TextSpan(
            text: date,
            style: TextStyle(color: pColor),
          )
        ],
      ),
    );
  }
}

class HolidayCard extends StatelessWidget {
  const HolidayCard(
    this.title, {
    super.key,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  final statusColor = Colors.yellowAccent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            "H",
            style: TextStyle(
              color: statusColor,
              fontSize: 24,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.read_more_rounded),
        onTap: onTap,
      ),
    );
  }
}

class LeaveCard extends StatelessWidget {
  const LeaveCard(
    this.title, {
    super.key,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  final statusColor = Colors.blueAccent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            "L",
            style: TextStyle(
              color: statusColor,
              fontSize: 24,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.read_more_rounded),
        onTap: onTap,
      ),
    );
  }
}

class AbsentCard extends StatelessWidget {
  const AbsentCard(
    this.title, {
    super.key,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  final statusColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            "A",
            style: TextStyle(
              color: statusColor,
              fontSize: 24,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.read_more_rounded),
        onTap: onTap,
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  const AttendanceCard(
    this.title, {
    super.key,
    required this.inTime,
    required this.outTime,
    required this.extraHourCount,
    this.onTap,
  });

  final Color statusColor = Colors.green;
  final String title;
  final String inTime;
  final String outTime;
  final int extraHourCount;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            "P",
            style: TextStyle(
              color: statusColor,
              fontSize: 24,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "In: $inTime -/- Out: $outTime\nExtra Hour Count: $extraHourCount",
          maxLines: 2,
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.read_more_rounded),
        onTap: onTap,
      ),
    );
  }
}

class ExtraHourCard extends StatelessWidget {
  const ExtraHourCard({
    super.key,
    required this.title,
    required this.count,
    this.onTap,
  });

  final String title;
  final int count;
  final void Function()? onTap;

  final Color statusColor = Colors.lightGreen;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Text(
            "E",
            style: TextStyle(
              color: statusColor,
              fontSize: 24,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Extra Hour Count: $count"),
        trailing: const Icon(Icons.read_more_rounded),
        onTap: onTap,
      ),
    );
  }
}

class ReportHeader extends StatelessWidget {
  const ReportHeader(
    this.title, {
    super.key,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
        ],
      ),
    );
  }
}

Widget numberBlock(String title, String value, Color color) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w200)),
        ],
      ),
    );
Widget timeBlock(String title, String value, Color color) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value, style: TextStyle(fontSize: 18, color: color)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w200)),
        ],
      ),
    );
