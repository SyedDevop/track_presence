import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/db/databse_helper.dart';
import 'package:vcare_attendance/db/profile_db.dart';

import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/screens/screen.dart';

// GoRouter configuration
final router = GoRouter(
  // initialLocation: RouteNames.reportPath,
  routes: [
    GoRoute(
      path: RouteNames.homePath,
      name: RouteNames.home,
      builder: (_, __) => const MyHomePage(),
    ),
    GoRoute(
      path: RouteNames.leavePath,
      name: RouteNames.leave,
      builder: (_, __) => const LeaveScreen(),
    ),
    GoRoute(
        path: RouteNames.profilePath,
        name: RouteNames.profile,
        builder: (_, state) {
          return ProfileScreen(
            id: state.pathParameters['id']!,
            imgPath: state.uri.queryParameters['img-path'],
          );
        }),
    GoRoute(
        path: RouteNames.accountPath,
        name: RouteNames.account,
        builder: (_, state) => const AccountScreen()),
    GoRoute(
      path: RouteNames.atReportPath,
      name: RouteNames.atReport,
      builder: (_, __) => const AtReportScreen(),
    ),
    GoRoute(
      path: RouteNames.stReportPath,
      name: RouteNames.stReport,
      builder: (_, __) => const StReportScreen(),
    ),
    GoRoute(
      path: RouteNames.clockPath,
      name: RouteNames.clock,
      builder: (_, state) {
        return ClockScreen(location: state.pathParameters["location"]!);
      },
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
    GoRoute(
      path: RouteNames.loginPath,
      name: RouteNames.login,
      builder: (_, __) => const LoginScreen(),
    ),
  ],
  redirect: (context, state) async {
    final DB db = DB.instance;
    final ProfileDB pdb = ProfileDB.instance;
    final user = await db.queryAllUsers();
    final profile = await pdb.queryAllProfile();
    final urlPath = state.uri.toString();

    if (profile.isEmpty) {
      if (urlPath == RouteNames.loginPath || urlPath == RouteNames.loginPath) {
        return null;
      }
      return RouteNames.loginPath;
    }
    if (user.isEmpty) {
      if (urlPath == RouteNames.registerScanPath ||
          urlPath == RouteNames.registerPath) return null;
      return RouteNames.registerPath;
    }
    return null;
  },
);
