import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/services/track_service.dart';
import 'package:vcare_attendance/theme/theme.dart';

Future<void> initTrackAndNotefication() async {
  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: kDebugMode,
      androidConfig: AndroidConfig(
        trackingInterval: Duration(seconds: 300),
        distanceFilterMeters: 0.0,
        notificationIcon: 'ic_launcher',
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        distanceFilterMeters: null,
        restartAfterKill: true,
      ),
    ),
  );
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'attandance_track_group',
        channelKey: 'attandance_track',
        channelName: 'Vcare Attendance Tracking',
        channelDescription: 'Vcare Attendance Tracking Notification',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        locked: true,
        importance: NotificationImportance.Max,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'attandance_track_group',
        channelGroupName: 'Vcare Attendance Tracking',
      )
    ],
    debug: kDebugMode,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await initTrackAndNotefication();
  initServices();
  runApp(const MyApp());
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
