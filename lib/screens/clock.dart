import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/api/error.dart';
import 'package:vcare_attendance/db/databse_helper.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/user_model.dart';
import 'package:vcare_attendance/services/camera_service.dart';
import 'package:vcare_attendance/services/face_detector_service.dart';
import 'package:vcare_attendance/services/ml_service.dart';
import 'package:vcare_attendance/services/track_service.dart';

import 'package:vcare_attendance/widgets/widget.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({
    super.key,
    required this.location,
  });

  /// Current location of the clocking attendance.
  final String location;

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final MLService _mlSR = getIt<MLService>();
  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isReasonRequared = false;

  bool _isUser = false;
  bool _initializing = false;
  bool _detectingFaces = false;
  bool _showBiometric = false;
  String? imagePath;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _camSR.dispose();
    _mlSR.dispose();
    _faceSR.dispose();
    super.dispose();
  }

  Future _start() async {
    setState(() => _initializing = true);

    await _camSR.initialize();
    await _mlSR.initialize();
    _faceSR.initialize();
    if (await auth.canCheckBiometrics) {
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        if (!_isUser) {
          setState(() => _showBiometric = true);
        }
      });
    }
    setState(() => _initializing = false);
    _frameFaces();
  }

  Future<void> _frameFaces() async {
    _camSR.cameraController!.startImageStream((CameraImage image) async {
      if (_camSR.cameraController != null) {
        if (_detectingFaces) return; // prevents unnecessary over processing.
        _detectingFaces = true;
        await _predictFacesFromImage(image);
        _detectingFaces = false;
      }
    });
  }

  Future<void> _savePic() async {
    final file = await _camSR.takePicture();
    imagePath = file?.path;
    final directory = await getExternalStorageDirectory();
    final imageData = await File(imagePath!).readAsBytes();
    final toImage = File("${directory?.path}/dp.jpg");
    await toImage.writeAsBytes(imageData);
    setState(() => _isUser = true);
  }

  Future<void> _predictFacesFromImage(CameraImage image) async {
    await _faceSR.detectFacesFromCam(image, _camSR.cameraRotation!);
    if (_faceSR.faceDetected) {
      await Future.delayed(const Duration(milliseconds: 100));
      _mlSR.setCurrentPrediction(image, _faceSR.faces[0]);
      User? user = await _mlSR.predict();
      if (user != null) {
        setState(() => _showBiometric = false);
        await _savePic();
        var attendSheetHandeler =
            scaffoldKey.currentState!.showBottomSheet((context) => attendSheet(
                  user,
                  "Mlface auth",
                ));
        if (mounted) attendSheetHandeler.closed.whenComplete(context.pop);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _onBioAuth() async {
    DB dbHelper = DB.instance;
    List<User> users = await dbHelper.queryAllUsers();
    await _savePic();
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to Clock Attendance',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        var attendSheetHandeler =
            scaffoldKey.currentState!.showBottomSheet((context) => attendSheet(
                  users.first,
                  "biometric auth",
                ));
        if (mounted) {
          attendSheetHandeler.closed.whenComplete(context.pop);
        }
      } else {
        if (mounted) context.pop();
      }
    } catch (_) {
      if (mounted) context.pop();
    }
  }

  Widget getBodyWidget() {
    if (_initializing) return const Center(child: CircularProgressIndicator());
    if (_isUser) return ImageView(imagePath: imagePath);
    return CameraPreviewBody();
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = getBodyWidget();

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          body,
          CameraHeader(
            "Clock Attendance",
            onBackPressed: _onBackPressed,
          ),
        ],
      ),
      floatingActionButton: _showBiometric
          ? IconButton.filledTonal(
              onPressed: _onBioAuth,
              icon: const Icon(
                Icons.fingerprint_rounded,
                size: 45,
              ),
            )
          : null,
    );
  }

  Container attendSheet(User user, String authType) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AttendanceBottomSheet(
        user: user,
        onStateChange: (e) => setState(() => _initializing = e),
        location: widget.location,
        authType: authType,
      ),
    );
  }
}

class AttendanceBottomSheet extends StatefulWidget {
  const AttendanceBottomSheet({
    super.key,
    required this.user,
    required this.onStateChange,
    required this.location,
    required this.authType,
  });

  /// [User] Current user
  final User user;

  /// [location] Current location of the user clocking.
  final String location;

  /// [authType] user Authenticated type for clocking attendance.
  final String authType;

  final void Function(bool value) onStateChange;
  @override
  State<AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  final _attendanceApi = Api.attendance;
  final _trackingSr = getIt<TrackingService>();
  final _reasonController = TextEditingController();
  bool _showReason = false;
  @override
  void dispose() {
    super.dispose();
    _reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.user.userName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 50),
        if (_showReason)
          TextField(
            controller: _reasonController,
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(labelText: "Reason "),
          ),
        const SizedBox(height: 50),
        TextButton.icon(
          onPressed: () async {
            widget.onStateChange(true);
            try {
              await _attendanceApi.postColock(
                widget.user.userId,
                'in',
                _reasonController.text,
                widget.location,
                widget.authType,
              );

              await _trackingSr.startTracking();
            } on DioException catch (e) {
              if (mounted) {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(e.message ?? ""),
                    );
                  },
                );
              }
              if (e.error == kReasonRequired || e.error == kShiftNotFound) {
                setState(() => _showReason = true);
              }
              return;
            } finally {
              if (mounted) widget.onStateChange(false);
            }
            if (mounted) context.pop();
          },
          icon: const Icon(Icons.more_time_rounded),
          label: const Text("Clock In"),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 25),
        TextButton.icon(
          onPressed: () async {
            widget.onStateChange(true);
            try {
              await _attendanceApi.postColock(
                widget.user.userId,
                'out',
                _reasonController.text,
                widget.location,
                widget.authType,
              );
              await _trackingSr.stopTracking();
            } on DioException catch (e) {
              await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text(e.message ?? ""),
                  );
                },
              );

              if (e.error == kReasonRequired) {
                setState(() => _showReason = true);
              }
              return;
            } finally {
              if (mounted) widget.onStateChange(false);
            }
            if (mounted) context.pop();
          },
          icon: const Icon(Icons.history_rounded),
          label: const Text("Clock Out"),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
