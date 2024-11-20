import 'dart:io';
import 'dart:math';

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
          UserAccountsDrawerHeader(
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
              color: Color.fromARGB(
                  220, 255, 255, 255), // Sets the background to white
              image: DecorationImage(
                image: AssetImage("assets/icons/vc-logo.png"),
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () => context.go("/"),
          ),
          ListTile(
            leading: const Icon(Icons.summarize_rounded),
            title: const Text('Report'),
            onTap: () => context.pushNamed(RouteNames.report),
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
}
