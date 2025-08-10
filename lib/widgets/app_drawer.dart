import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/services/app_state.dart';
import 'package:vcare_attendance/utils/token_storage.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AppStore _appSr = getIt<AppStore>();

  @override
  Widget build(BuildContext context) {
    String? imgPath = _appSr.profileImagePathCached;
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _avater(imgPath),
                ListTile(
                  leading: const Icon(Icons.summarize_rounded),
                  title: const Text('Attendance Report'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouteNames.atReport);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Shifts Report'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouteNames.stReport);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.currency_rupee_rounded),
                  title: const Text('Payroll Report'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouteNames.payrollDay);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flight_rounded),
                  title: const Text('Leaves'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouteNames.leave);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.credit_score_rounded),
                  title: const Text('Loan'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(RouteNames.loan);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_2_rounded),
                  title: const Text('Profile'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(
                      RouteNames.profile,
                      pathParameters: {"id": _appSr.token.id},
                      queryParameters: {"img-path": imgPath},
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle_rounded),
                  title: const Text('Account'),
                  onTap: () {
                    context.pop();
                    context.pushNamed(
                      RouteNames.account,
                      pathParameters: {"id": _appSr.token.id},
                      queryParameters: {"img-path": imgPath},
                    );
                  },
                ),
              ],
            ),
          ),
          // ------------ End

          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Log Out'),
            onTap: () async {
              final storage = TokenStorage();
              // final udb = DB.instance;
              // await storage.clear();
              await storage.clearAccess();
              // await udb.deleteAll();

              if (mounted) context.pushNamed(RouteNames.login);
            },
          ),
        ],
      ),
    );
  }

  UserAccountsDrawerHeader _avater(String? imgPath) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: imgPath != null && imgPath.isNotEmpty
          ? CircleAvatar(backgroundImage: FileImage(File(imgPath)))
          : const CircleAvatar(
              child: ClipOval(
                child: Icon(
                  Icons.account_circle_sharp,
                  size: 70,
                ),
              ),
            ),
      accountName: Text(_appSr.token.name),
      accountEmail: Text(_appSr.token.id),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F8F8), // Sets the background to white
        image: DecorationImage(
          image: AssetImage("assets/icons/vc-logo.png"),
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }
}
