import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/api/error.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/user_model.dart';
import 'package:vcare_attendance/services/camera_service.dart';
import 'package:vcare_attendance/services/face_detector_service.dart';
import 'package:vcare_attendance/services/ml_service.dart';
import 'package:vcare_attendance/widgets/cam_header.dart';
import 'package:vcare_attendance/widgets/camra_preview_body.dart';
import 'package:vcare_attendance/widgets/image_view.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  final MLService _mlSR = getIt<MLService>();
  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final _reasonController = TextEditingController();
  bool isReasonRequared = false;

  bool _isUser = false;
  bool _initializing = false;
  bool _detectingFaces = false;
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
    setState(() => _initializing = false);
    _frameFaces();
  }

  _frameFaces() async {
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
      await Future.delayed(const Duration(milliseconds: 200));
      _mlSR.setCurrentPrediction(image, _faceSR.faces[0]);
      User? user = await _mlSR.predict();
      if (user != null) {
        await _savePic();
        var attendSheetHandeler = scaffoldKey.currentState!
            .showBottomSheet((context) => attendSheet(user));
        if (mounted) attendSheetHandeler.closed.whenComplete(context.pop);
      }
    }
    if (mounted) setState(() {});
  }

  Widget getBodyWidget() {
    if (_initializing) return const Center(child: CircularProgressIndicator());
    if (_isUser) return ImageView(imagePath: imagePath);
    return CameraPreviewBody();
  }

  _onBackPressed() {
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
    );
  }

  attendSheet(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            user.userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 50),
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
              setState(() => _initializing = true);
              try {
                await Api.postColock(user.userId, 'in', _reasonController.text);
              } on ApiException catch (e) {
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text(e.message),
                      );
                    },
                  );
                }
                return;
              } finally {
                if (mounted) setState(() => _initializing = false);
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
              setState(() => _initializing = true);
              try {
                await Api.postColock(
                    user.userId, 'out', _reasonController.text);
              } on ApiException catch (e) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(e.message),
                    );
                  },
                );
                return;
              } finally {
                setState(() => _initializing = false);
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
      ),
    );
  }
}
