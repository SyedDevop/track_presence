import 'package:go_router/go_router.dart';
import 'package:track_presence/db/databse_helper.dart';

import 'package:track_presence/router/router_name.dart';
import 'package:track_presence/screens/home.dart';
import 'package:track_presence/screens/register.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: RouteNames.homePath,
      name: RouteNames.home,
      builder: (_, __) => const MyHomePage(),
    ),
    GoRoute(
      path: RouteNames.registerPath,
      name: RouteNames.register,
      builder: (_, __) => const Register(),
    )
  ],
  redirect: (context, state) async {
    final DB db = DB.instance;
    final user = await db.queryAllUsers();
    if (user.isEmpty) return RouteNames.registerPath;
    return null;
  },
);
