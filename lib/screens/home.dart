import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/db/databse_helper.dart';
import 'package:vcare_attendance/models/time.dart';
import 'package:vcare_attendance/models/user_model.dart';
import 'package:vcare_attendance/router/router_name.dart';

const gap = 15.0;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ShiftTime? shiftTime;
  String strSiftTime = "---:--- / ---:---";
  String strClockTime = "---:--- / ---:---";
  ClockedTime? clockedTime;
  @override
  void initState() {
    super.initState();
    _getTimes();
  }

  Future<void> _getTimes() async {
    DB dbHelper = DB.instance;
    List<User> users = await dbHelper.queryAllUsers();
    final gotsShiftTime = await Api.getShifttime(users[0].userId);
    final gotClockedTime = await Api.getColockedtime(users[0].userId);

    setState(() {
      shiftTime = gotsShiftTime;
      clockedTime = gotClockedTime;
      if (gotsShiftTime != null) {
        strSiftTime = "${gotsShiftTime.fromTime} -/- ${gotsShiftTime.toTime}";
      }
      strClockTime =
          "${gotClockedTime?.inTime ?? "---:---"} -/- ${gotClockedTime?.outTime ?? "---:---"}";
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getTimes,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                TimeInfo(
                  header: "Shift",
                  childens: [
                    TimePrimeryView(time: strSiftTime),
                    const SizedBox(height: 10),
                    TimeSecondaryView(
                        time: shiftTime?.shiftHours ?? "-- hr -- min"),
                  ],
                ),
                const SizedBox(height: gap),
                TimeInfo(header: "Attendance", childens: [
                  TimePrimeryView(time: strClockTime),
                  const SizedBox(height: 10),
                  TimeSecondaryView(
                      time: clockedTime?.clockHours ?? "-- hr -- min"),
                  const Divider(),
                  TimeSecondaryView(
                    icon: const Icon(
                      Icons.hourglass_empty_rounded,
                      color: Colors.redAccent,
                    ),
                    time: "Loss Of Time : ${clockedTime?.lossOfTime ?? "----"}",
                  ),
                  const SizedBox(height: 5),
                  TimeSecondaryView(
                    icon: const Icon(
                      Icons.alarm_add,
                      color: Colors.tealAccent,
                    ),
                    time: "Over Time : ${clockedTime?.overTime ?? "----"}",
                  ),
                ]),
                const SizedBox(height: gap),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: () async {
          await context.pushNamed(RouteNames.clock);
          await _getTimes();
        },
        label: const Text("Clock Attendance"),
        icon: const Icon(Icons.door_front_door_rounded),
      ),
    );
  }
}

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.stat1key,
    required this.stat1value,
    required this.stat2key,
    required this.stat2value,
  });
  final String stat1key;
  final String stat1value;
  final String stat2key;
  final String stat2value;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).highlightColor,
      ),
      child: Wrap(
        // direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        children: [
          StatBlock(statKey: stat1key, statValue: stat1value),
          StatBlock(statKey: stat2key, statValue: stat2value),
        ],
      ),
    );
  }
}

class StatBlock extends StatelessWidget {
  const StatBlock({
    super.key,
    required this.statKey,
    required this.statValue,
  });
  final String statKey;
  final String statValue;
  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w400,
      color: Theme.of(context).hintColor,
    );
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(statKey, style: titleStyle),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 25,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Theme.of(context).dialogBackgroundColor,
            ),
            child: Text(statValue),
          ),
        ],
      ),
    );
  }
}

class TimeInfo extends StatelessWidget {
  const TimeInfo({
    super.key,
    required this.header,
    required this.childens,
  });

  final String header;
  final List<Widget> childens;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).hintColor,
              ),
            ),
            const Divider(),
            ...childens,
          ],
        ),
      ),
    );
  }
}

class TimeSecondaryView extends StatelessWidget {
  const TimeSecondaryView({
    super.key,
    required this.time,
    this.icon,
  });
  final String time;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon ??
            Icon(
              Icons.timer_outlined,
              color: Theme.of(context).primaryColorDark,
            ),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

class TimePrimeryView extends StatelessWidget {
  const TimePrimeryView({
    super.key,
    required this.time,
  });

  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.access_time_rounded,
          color: Theme.of(context).primaryColorLight,
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white70, // Slightly lighter than white
          ),
        ),
      ],
    );
  }
}

class TimeView extends StatelessWidget {
  const TimeView({
    super.key,
    required this.header,
    required this.timer1title,
    required this.timer1time,
    required this.timer2title,
    required this.timer2time,
  });

  final String header;
  final String timer1title;
  final String timer1time;
  final String timer2title;
  final String timer2time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).dialogBackgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TimeBlock(title: timer1title, time: timer1time),
              TimeBlock(title: timer2title, time: timer2time),
            ],
          ),
        ],
      ),
    );
  }
}

class TimeBlock extends StatelessWidget {
  const TimeBlock({
    super.key,
    required this.title,
    required this.time,
  });

  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    final timeTitleStyle = TextStyle(
      fontWeight: FontWeight.w400,
      color: Theme.of(context).hintColor,
    );

    const timeStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: timeTitleStyle),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 50,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).highlightColor,
          ),
          child: Text(time, style: timeStyle),
        ),
      ],
    );
  }
}
