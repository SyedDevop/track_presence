import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/db/databse_helper.dart';

import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/screens/clock.dart';
import 'package:vcare_attendance/screens/home.dart';
import 'package:vcare_attendance/screens/register.dart';
import 'package:vcare_attendance/screens/register_scan.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: RouteNames.homePath,
      name: RouteNames.home,
      builder: (_, __) => const MyHomePage(),
    ),
    GoRoute(
      path: RouteNames.clockPath,
      name: RouteNames.clock,
      builder: (_, __) => const ClockScreen(),
    ),
    GoRoute(
      path: RouteNames.registerPath,
      name: RouteNames.register,
      builder: (_, __) => const Register(),
    ),
    GoRoute(
      path: RouteNames.registerScanPath,
      name: RouteNames.registerScan,
      builder: (_, __) => const RegisterScan(),
    ),
  ],
  redirect: (context, state) async {
    final DB db = DB.instance;
    final user = await db.queryAllUsers();

    final urlPath = state.uri.toString();

    if (user.isEmpty) {
      if (urlPath == RouteNames.registerScanPath ||
          urlPath == RouteNames.registerPath) return null;
      return RouteNames.registerPath;
    }
    return null;
  },
);
