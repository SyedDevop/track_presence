import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
