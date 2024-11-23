import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/services/state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final AppState _asSr = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    String? imgPath = _asSr.localProfile?.imgPath;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _avater(imgPath),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go("/");
            },
          ),
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
            leading: const Icon(Icons.person_2_rounded),
            title: const Text('Profile'),
            onTap: () => {},
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
      accountName: Text(_asSr.profile?.name ?? "Name"),
      accountEmail: Text(_asSr.profile?.userId ?? "Id"),
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
