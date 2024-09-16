import 'package:flutter/material.dart';

import 'package:track_presence/getit.dart';
import 'package:track_presence/router/router.dart';
import 'package:track_presence/theme/theme.dart';

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
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
