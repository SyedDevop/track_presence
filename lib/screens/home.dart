import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/constant/department.dart';
import 'package:vcare_attendance/constant/location.dart';
import 'package:vcare_attendance/db/profile_db.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/profile_model.dart';
import 'package:vcare_attendance/models/time.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/services/app_state.dart';
import 'package:vcare_attendance/services/state.dart' as local;
import 'package:vcare_attendance/snackbar/snackbar.dart';
import 'package:vcare_attendance/utils/utils.dart';

import 'package:vcare_attendance/widgets/widget.dart';

const gap = 15.0;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _attendanceApi = Api.attendance;
  final _shiftApi = Api.shift;

  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final local.AppState _asSr = getIt<local.AppState>();
  final _astSr = getIt<AppStore>();

  bool _initializing = false;
  ShiftTime? shiftTime;
  String strSiftTime = "---:--- / ---:---";
  String strSiftdate = "--:--:---- / --:--:----";
  String strClockTime = "---:--- / ---:---";
  Attendance? clockedTime;
  List<ExtraHours>? overTime;

  @override
  void initState() {
    super.initState();
    _getTimes();
    // loadAd();
  }

  Future<void> _getTimes() async {
    try {
      setState(() => _initializing = true);
      final userId = _astSr.token.id;
      final gotsShiftTime = await _shiftApi.getShifttime(userId);
      final gotClockedTime = await _attendanceApi.getColockedtime(userId);
      final gotOt = await _attendanceApi.getOvertime(userId);
      await _asSr.initProfile(userId);

      setState(() {
        shiftTime = gotsShiftTime;
        clockedTime = gotClockedTime;
        if (gotsShiftTime != null) {
          strSiftTime =
              "${gotsShiftTime.fromTime}\n To \n${gotsShiftTime.toTime}";
          strSiftdate = "${gotsShiftTime.fromDate} -/- ${gotsShiftTime.toDate}";
        }
        strClockTime =
            "${gotClockedTime?.inTime ?? "---:---"}\n To \n${gotClockedTime?.outTime ?? "---:---"}";
        if (gotOt.isNotEmpty) {
          overTime = gotOt;
        } else {
          overTime = null;
        }
      });
    } finally {
      setState(() => _initializing = false);
    }
    return;
  }

  bool _isExempt(String? department, String? empId) {
    return kExemptDepartments.contains(department) || empId == 'VCH0000';
  }

  Future<void> _navigateToClock(Position currPos) async {
    if (!mounted) return;
    await context.pushNamed(
      RouteNames.clock,
      pathParameters: {
        'location': '${currPos.latitude} , ${currPos.longitude}',
      },
    );
  }

  bool _isOnSite(Position currPos) {
    return kCoords.any((coord) {
      final dist = Geolocator.distanceBetween(
        coord.lat,
        coord.long,
        currPos.latitude,
        currPos.longitude,
      );
      debugPrint('[Info] Distance to ${coord.name}: $dist meters');
      return dist <= kMinDistance;
    });
  }

  Future<void> _handleClock() async {
    if (_initializing) return;
    setState(() => _initializing = true);
    try {
      final currPoss = await _determinePosition();
      final dep = _asSr.employee?.companyDetails?.department;
      final id = _asSr.employee?.personalDetails?.empId;

      // 1) Exempt users always allowed
      if (_isExempt(dep, id)) {
        debugPrint('[Info] Exempt user Department:$dep and id:$id');
        await _navigateToClock(currPoss);
        await _getTimes();
        return;
      }
      // 2) Regular users must be on-site
      if (_isOnSite(currPoss)) {
        await _navigateToClock(currPoss);
        await _getTimes();
        return;
      }
      snackbarNotefy(
        context,
        message:
            'You are currently not on-site and cannot clock in your attendance.',
        duration: 5,
      );
    } catch (e) {
      debugPrint('[Error] Couldn’t get location: $e');
      snackbarNotefy(
        context,
        message: 'Couldn’t get location: $e',
        duration: 5,
      );
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  BannerAd? _bannerAd;
  final bool _isAdLoaded = false;
  // final adUnitId = 'ca-app-pub-2791763544217577/3961842060';
  //
  // void loadAd() async {
  //   _bannerAd = BannerAd(
  //     adUnitId: adUnitId,
  //     request: const AdRequest(),
  //     size: AdSize.banner,
  //     listener: BannerAdListener(
  //       // Called when an ad is successfully received.
  //       onAdLoaded: (ad) {
  //         debugPrint('$ad loaded.');
  //         setState(() => _isAdLoaded = true);
  //       },
  //       // Called when an ad request failed.
  //       onAdFailedToLoad: (ad, err) {
  //         debugPrint('BannerAd failed to load: $err');
  //         // Dispose the ad here to free resources.
  //         ad.dispose();
  //       },
  //     ),
  //   )..load();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          if (_bannerAd != null && _isAdLoaded)
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
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
                              TimePrimeryView(time: strSiftTime, fontSize: 14),
                              const SizedBox(height: 10),
                              TimeSecondaryView(
                                time: shiftTime?.shiftHours ?? "-- hr -- min",
                              ),
                              const Divider(),
                              TimeSecondaryView(time: strSiftdate),
                            ],
                          ),
                          const SizedBox(height: gap),
                          TimeInfo(header: "Attendance", childens: [
                            TimePrimeryView(time: strClockTime),
                            const SizedBox(height: 10),
                            TimeSecondaryView(
                              time: clockedTime?.clockHours ?? "-- hr -- min",
                            ),
                            const Divider(),
                            TimeSecondaryView(
                              icon: const Icon(
                                Icons.hourglass_empty_rounded,
                                color: Colors.redAccent,
                              ),
                              time:
                                  "Loss Of Time : ${minToHrMin(clockedTime?.lossOfTime)}",
                            ),
                            const SizedBox(height: 5),
                            TimeSecondaryView(
                              icon: const Icon(
                                Icons.alarm_add,
                                color: Colors.tealAccent,
                              ),
                              time:
                                  "Over Time : ${minToHrMin(clockedTime?.overTime)}",
                            ),
                          ]),
                          const SizedBox(height: gap),
                          if (overTime != null)
                            TimeInfo(
                              header: "Extra Hours",
                              childens: overTime!
                                  .map((ot) => ExtraHourInfo(ot))
                                  .toList(),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                if (_initializing)
                  Container(
                    color: Colors.black.withOpacity(0.75),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FilledButton.icon(
        onPressed: _handleClock,
        label: const Text("Clock Attendance"),
        icon: const Icon(Icons.door_front_door_rounded),
      ),
    );
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await Geolocator.openLocationSettings();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
  );

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
    locationSettings: locationSettings,
  );
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

class ExtraHourInfo extends StatelessWidget {
  const ExtraHourInfo(
    this.data, {
    super.key,
  });

  final ExtraHours data;

  String _fmtTime() {
    if (data.outTime == null) {
      return "${data.inTime} -/- ---:---";
    }
    return "${data.inTime} -/- ${data.outTime}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TimePrimeryView(time: _fmtTime()),
        const SizedBox(height: 16),
        const Text("Reason: ",
            style: TextStyle(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(height: 4),
        Text(
          data.reason,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
          ),
        ),
        const Divider(),
      ],
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
    this.fontSize = 16,
  });

  final String time;
  final double? fontSize;

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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
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
