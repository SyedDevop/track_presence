import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/router/router_name.dart';
import 'package:vcare_attendance/services/service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final MLService _mlSR = getIt<MLService>();
  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();
  final AppStore _appSr = getIt<AppStore>();

  @override
  void initState() {
    super.initState();
    _mlSR.initialize();
    _camSR.initialize();
    _faceSR.initialize();
    _appSr.initialize();
  }

  @override
  void dispose() {
    _camSR.dispose();
    _mlSR.dispose();
    _faceSR.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 55,
                  horizontal: 10,
                ),
                child: Text(
                  "Register Face ID",
                  style: TextStyle(fontSize: 38),
                ),
              ),
              const Expanded(child: SizedBox()),
              Center(
                child: SvgPicture.asset(
                  "assets/svg/face.svg",
                  width: 65,
                  height: 65,
                  color: Colors.white54,
                ),
              ),
              const Expanded(child: SizedBox()),
              const Text(
                "Face ID",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Text(
                "Use Face ID to register in to your",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Text(
                "Vcare Attendance account",
                style: TextStyle(
                  color: Color.fromRGBO(175, 175, 175, 1),
                ),
              ),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: FilledButton(
                  onPressed: () => context.pushNamed(RouteNames.registerScan),
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
