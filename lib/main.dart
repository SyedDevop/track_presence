// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/theme/theme.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

// Be sure to annotate your callback for Flutter >= 3.3.0
@pragma('vm:entry-point')
void headlessTask(bg.HeadlessEvent headlessEvent) async {
  print('[BackgroundGeolocation HeadlessTask]: $headlessEvent');
  // Implement a 'case' for only those events you're interested in.
  switch (headlessEvent.name) {
    case bg.Event.TERMINATE:
      bg.State state = headlessEvent.event;
      print('- State: $state');
      break;
    case bg.Event.HEARTBEAT:
      bg.HeartbeatEvent event = headlessEvent.event;
      print('- HeartbeatEvent: $event');
      break;
    case bg.Event.LOCATION:
      bg.Location location = headlessEvent.event;
      print('- Location: $location');
      break;
    case bg.Event.MOTIONCHANGE:
      bg.Location location = headlessEvent.event;
      print('- Location: $location');
      break;
    case bg.Event.GEOFENCE:
      bg.GeofenceEvent geofenceEvent = headlessEvent.event;
      print('- GeofenceEvent: $geofenceEvent');
      break;
    case bg.Event.GEOFENCESCHANGE:
      bg.GeofencesChangeEvent event = headlessEvent.event;
      print('- GeofencesChangeEvent: $event');
      break;
    case bg.Event.SCHEDULE:
      bg.State state = headlessEvent.event;
      print('- State: $state');
      break;
    case bg.Event.ACTIVITYCHANGE:
      bg.ActivityChangeEvent event = headlessEvent.event;
      print('ActivityChangeEvent: $event');
      break;
    case bg.Event.HTTP:
      bg.HttpEvent response = headlessEvent.event;
      print('HttpEvent: $response');
      break;
    case bg.Event.POWERSAVECHANGE:
      bool enabled = headlessEvent.event;
      print('ProviderChangeEvent: $enabled');
      break;
    case bg.Event.CONNECTIVITYCHANGE:
      bg.ConnectivityChangeEvent event = headlessEvent.event;
      print('ConnectivityChangeEvent: $event');
      break;
    case bg.Event.ENABLEDCHANGE:
      bool enabled = headlessEvent.event;
      print('EnabledChangeEvent: $enabled');
      break;
  }
}
// Future<void> initTrackAndNotefication() async {
//   await BackgroundLocationTrackerManager.initialize(
//     backgroundCallback,
//     config: const BackgroundLocationTrackerConfig(
//       loggingEnabled: kDebugMode,
//       androidConfig: AndroidConfig(
//         trackingInterval: Duration(seconds: 300),
//         distanceFilterMeters: 0.0,
//         notificationIcon: 'ic_launcher',
//       ),
//       iOSConfig: IOSConfig(
//         activityType: ActivityType.FITNESS,
//         distanceFilterMeters: null,
//         restartAfterKill: true,
//       ),
//     ),
//   );
//   AwesomeNotifications().initialize(
//     null,
//     [
//       NotificationChannel(
//         channelGroupKey: 'attandance_track_group',
//         channelKey: 'attandance_track',
//         channelName: 'Vcare Attendance Tracking',
//         channelDescription: 'Vcare Attendance Tracking Notification',
//         defaultColor: Color(0xFF9D50DD),
//         ledColor: Colors.white,
//         locked: true,
//         importance: NotificationImportance.Max,
//       )
//     ],
//     channelGroups: [
//       NotificationChannelGroup(
//         channelGroupKey: 'attandance_track_group',
//         channelGroupName: 'Vcare Attendance Tracking',
//       )
//     ],
//     debug: kDebugMode,
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  // await initTrackAndNotefication();
  initServices();
  runApp(const MyApp());
  bg.BackgroundGeolocation.registerHeadlessTask(headlessTask);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> initPlatformState() async {
    await Permission.location.request();
    await Permission.notification.request();
    await Permission.camera.request();
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Vcare Attendance',
      theme: FTTheme.light,
      darkTheme: FTTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
