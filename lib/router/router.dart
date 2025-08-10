import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/db/databse_helper.dart';

import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/screens/live_camera.dart';
import 'package:vcare_attendance/screens/loan/loan.dart';
import 'package:vcare_attendance/screens/loan/loan_summery.dart';
import 'package:vcare_attendance/screens/payroll/payroll_day.dart';
import 'package:vcare_attendance/screens/payroll/payroll_month.dart';
import 'package:vcare_attendance/screens/screen.dart';
import 'package:vcare_attendance/screens/task/main.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

// GoRouter configuration
final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  // initialLocation: RouteNames.tasksPath,
  routes: [
    GoRoute(
      path: RouteNames.homePath,
      name: RouteNames.home,
      builder: (_, __) => const MyHomePage(),
    ),
    GoRoute(
      path: RouteNames.tasksPath,
      name: RouteNames.tasks,
      builder: (_, __) => const TasksScreen(),
    ),
    GoRoute(
        path: RouteNames.taskDetailPath,
        name: RouteNames.taskDetail,
        builder: (_, state) {
          return TaskDetailScreen(taskId: state.pathParameters['id']!);
        }),
    GoRoute(
      path: RouteNames.taskCompletionPath,
      name: RouteNames.taskCompletion,
      builder: (context, state) {
        return TaskCompletionScreen(taskId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: RouteNames.liveCameraPath,
      name: RouteNames.liveCamera,
      builder: (context, state) => const LiveCameraScreen(),
    ),
    GoRoute(
      path: RouteNames.leavePath,
      name: RouteNames.leave,
      builder: (_, __) => const LeaveScreen(),
    ),
    GoRoute(
      path: RouteNames.loanPath,
      name: RouteNames.loan,
      builder: (_, __) => const LoanScreen(),
    ),
    GoRoute(
        path: RouteNames.loanSummeryPath,
        name: RouteNames.loanSummery,
        builder: (_, state) {
          return LoanSummeryScreen(id: state.pathParameters['id']!);
        }),
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
    ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (_, __, Widget child) =>
            PayrollScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: RouteNames.payrollDayPath,
            name: RouteNames.payrollDay,
            builder: (_, __) => const PayrollDayScreen(),
          ),
          GoRoute(
            path: RouteNames.payrollMonthPath,
            name: RouteNames.payrollMonth,
            builder: (_, __) => const PayrollMonthScreen(),
          )
        ]),
  ],
  redirect: (context, state) async {
    final storage = TokenStorage();
    final rawToken = await storage.accessToken;
    final urlPath = state.uri.toString();

    // If no token stored → must login
    if (rawToken == null) {
      // If already on login, no redirect; otherwise send to login
      if (urlPath == RouteNames.loginPath || urlPath == RouteNames.loginPath) {
        return null;
      }
      return RouteNames.loginPath;
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final DB db = DB.instance;
    final user = await db.queryAllUsers();
    if (user.isEmpty && androidInfo.isPhysicalDevice) {
      if (urlPath == RouteNames.registerScanPath ||
          urlPath == RouteNames.registerPath) {
        return null;
      }
      return RouteNames.registerPath;
    }
    return null;
  },
);

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where [child] is placed in the body of the Scaffold.
class PayrollScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [PayrollScaffoldWithNavBar].
  const PayrollScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  /// The widget to display in the body of the Scaffold.
  /// In this sample, it is a Navigator.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      appBar: AppBar(title: const Text("Payroll")),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today_rounded),
            label: 'Day\'s',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Month\'s',
          ),
        ],
        currentIndex: _calculateSelectedIndex(context),
        onTap: (int idx) => _onItemTapped(idx, context),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location == RouteNames.payrollDayPath) {
      return 0;
    }
    if (location == RouteNames.payrollMonthPath) {
      return 1;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).pushNamed(RouteNames.payrollDay);
      case 1:
        GoRouter.of(context).pushNamed(RouteNames.payrollMonth);
    }
  }
}
