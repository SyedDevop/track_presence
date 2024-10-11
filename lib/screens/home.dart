import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_presence/api/api.dart';
import 'package:track_presence/db/databse_helper.dart';
import 'package:track_presence/models/time.dart';
import 'package:track_presence/models/user_model.dart';
import 'package:track_presence/router/router_name.dart';

const gap = 15.0;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ShiftTime? shiftTime;
  ClockedTime? clockedTime;
  @override
  void initState() {
    super.initState();
    _getShiftTime();
  }

  _getShiftTime() async {
    DB dbHelper = DB.instance;
    List<User> users = await dbHelper.queryAllUsers();
    final gotsShiftTime = await Api.getShifttime(users[0].userId);
    final gotClockedTime =
        await Api.getColockedtime(users[0].userId, date: "09-10-2024");
    setState(() {
      shiftTime = gotsShiftTime;
      clockedTime = gotClockedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            TimeView(
              header: "Shift Time",
              timer1title: "From",
              timer1time: shiftTime?.fromTime ?? "----",
              timer2title: "To",
              timer2time: shiftTime?.toTime ?? "----",
            ),
            const SizedBox(height: gap),
            TimeView(
              header: "Clocked Attendance",
              timer1title: "From",
              timer1time: clockedTime?.inTime ?? "----",
              timer2title: "To",
              timer2time: clockedTime?.outTime ?? "----",
            ),
            const SizedBox(height: gap),
            StatBar(
              stat1key: "Loss of time : ",
              stat1value: clockedTime?.lossOfTime ?? "----",
              stat2key: "Over time : ",
              stat2value: clockedTime?.overTime ?? "----",
            ),
            const SizedBox(height: gap),
          ],
        ),
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: () => context.pushNamed(RouteNames.clock),
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
