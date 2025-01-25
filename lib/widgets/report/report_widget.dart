import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:vcare_attendance/models/report_model.dart';
import 'package:vcare_attendance/utils/utils.dart';

enum ReportType { attendance, extraHour }

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

class FullExtraHoursReport extends StatelessWidget {
  const FullExtraHoursReport({
    super.key,
    required this.extraHour,
    required this.extraHourDate,
  });

  final List<ExtraHourReport> extraHour;
  final String extraHourDate;

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
              const Divider(),
              ...genrateExtraHours(extraHour),
            ],
          ),
        ),
      ),
    );
  }
}

Iterable<Widget> genrateExtraHours(List<ExtraHourReport> exHr) {
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
    required this.item,
  });

  final AttendanceReport item;

  @override
  Widget build(BuildContext context) {
    final shiftHours = calDiff(item.inTime, item.outTime);
    final shiftHoursStr = durationToHrMin(shiftHours);
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportSheetTitle(date: item.date1),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.update_rounded,
                leadingText: "In Time: ",
                trailingText: item.inTime,
              ),
              ReportSheetRow(
                leadingIcon: Icons.history_rounded,
                leadingText: "Out Time:",
                trailingText: item.outTime,
              ),
              ReportSheetRow(
                leadingIcon: Icons.work_history,
                leadingText: "Working Hours:",
                trailingText: shiftHoursStr,
              ),
              ReportSheetRow(
                leadingIcon: Icons.hourglass_bottom_rounded,
                leadingText: "Loss Of Hours:",
                trailingText: minToHrMin(item.lossOfHours),
              ),
              ReportSheetRow(
                leadingIcon: Icons.alarm_add_rounded,
                leadingText: "Over time:",
                trailingText: minToHrMin(item.maintainance),
              ),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.schedule_rounded,
                leadingText: "Shift Timing:",
                trailingText: item.shiftTime,
              ),
              const Divider(),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason:",
                trailingText: item.reason,
              ),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason For Late:",
                trailingText: item.reasonLate,
              ),
              ReportSheetRow(
                leadingIcon: Icons.help_rounded,
                leadingText: "Reason For Early:",
                trailingText: item.reasonEarly,
              ),
              if (item.extraHours.isNotEmpty) const Divider(),
              ...genrateExtraHours(item.extraHours),
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
  });

  final IconData? leadingIcon;
  final String leadingText;
  final String? trailingText;

  TextStyle _leadTextStyle(BuildContext context) =>
      TextStyle(color: Theme.of(context).colorScheme.secondaryFixed);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

class AttendanceCard extends StatelessWidget {
  const AttendanceCard(
    this.title, {
    super.key,
    required this.statusColor,
    required this.inTime,
    required this.outTime,
    required this.extraHourCount,
    this.onTap,
  });

  final Color statusColor;
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
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.calendar_today_rounded, color: statusColor),
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
    required this.statusColor,
    required this.title,
    required this.count,
    this.onTap,
  });

  final Color statusColor;
  final String title;
  final int count;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.calendar_today_rounded, color: statusColor),
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
