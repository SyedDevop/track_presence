import 'package:flutter/material.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router.dart';
import 'package:vcare_attendance/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Track Presence',
      theme: FTTheme.light,
      darkTheme: FTTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
