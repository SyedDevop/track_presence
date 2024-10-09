import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_presence/router/router_name.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton.icon(
              onPressed: () => context.pushNamed(RouteNames.clock),
              label: const Text("Clock Attendance"),
              icon: const Icon(Icons.door_front_door_rounded),
            )
          ],
        ),
      ),
    );
  }
}
