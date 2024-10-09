import 'package:go_router/go_router.dart';
import 'package:track_presence/db/databse_helper.dart';

import 'package:track_presence/router/router_name.dart';
import 'package:track_presence/screens/clock.dart';
import 'package:track_presence/screens/home.dart';
import 'package:track_presence/screens/register.dart';
import 'package:track_presence/screens/register_scan.dart';

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
