import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:vcare_attendance/db/databse_helper.dart';
import 'package:vcare_attendance/db/profile_db.dart';
import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/models/user_model.dart';
import 'package:vcare_attendance/services/camera_service.dart';
import 'package:vcare_attendance/services/face_detector_service.dart';
import 'package:vcare_attendance/services/ml_service.dart';
import 'package:vcare_attendance/snackbar/snackbar.dart';
import 'package:vcare_attendance/widgets/cam_header.dart';
import 'package:vcare_attendance/widgets/camra_preview_body.dart';
import 'package:vcare_attendance/widgets/image_view.dart';

class RegisterScan extends StatefulWidget {
  const RegisterScan({super.key});

  @override
  State<RegisterScan> createState() => _RegisterScanState();
}

class _RegisterScanState extends State<RegisterScan> {
  final MLService _mlSR = getIt<MLService>();
  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();

  int captureCount = 0;
  final captureLimit = 6;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? imagePath;
  String? imgSavedPath;
  Face? faceDetected;

  bool _saving = false;
  bool pictureTaken = false;
  bool _initializing = false;
  bool _detectingFaces = false;

  @override
  void initState() {
    super.initState();
    _start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Capture $captureLimit Face for more accuracies'),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _camSR.dispose();
  }

  Future _start() async {
    setState(() => _initializing = true);
    await _camSR.initialize();
    setState(() => _initializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    _camSR.cameraController?.startImageStream((image) async {
      if (_camSR.cameraController != null) {
        if (_detectingFaces) return; // If image is in process return;
        _detectingFaces = true;

        try {
          await _faceSR.detectFacesFromCam(image, _camSR.cameraRotation!);
          if (_faceSR.faceDetected) {
            setState(() => faceDetected = _faceSR.faces[0]);

            if (_saving) {
              _mlSR.setCurrentPrediction(image, faceDetected);
              captureCount = _mlSR.predictedDataList.length;
              setState(() => _saving = false); // NOTE : Is this require
            }
          } else {
            setState(() => faceDetected = null); // NOTE : Is this require
          }
          _detectingFaces = false;
        } catch (e) {
          print('Error _faceDetectorService face => $e');
          _detectingFaces = false;
        }
      }
    });
  }

  Future<bool> saveData() async {
    if (!(captureCount >= captureLimit - 1)) return false;
    await onShot();

    //TODO: Save the Captured photo to server and locally.
    DB udb = DB.instance;
    ProfileDB pdb = ProfileDB.instance;

    final pros = await pdb.queryAllProfile();

    if (pros.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('User Profile not found'),
          );
        },
      );
      return false;
    }
    final pro = pros[0];
    final Database db = await pdb.database;
    print("Image Path => :: $imagePath");
    print("Image Saved Path => :: $imgSavedPath");
    db.rawUpdate(
      'UPDATE ${ProfileDB.table} SET img_path = "${imgSavedPath ?? ""}" WHERE user_id = "${pro.userId}"',
    );
    for (var data in _mlSR.predictedDataList) {
      User userToSave = User(
        userId: pro.userId,
        userName: pro.name,
        modelData: data,
      );
      await udb.insert(userToSave);
    }

    _mlSR.resetPredicted();
    return true;
  }

  Future onCapture(BuildContext context) async {
    _saving = true;
    final isDataSaved = await saveData();

    if (isDataSaved) {
      if (mounted) {
        snackbarSuccess(
          context,
          message:
              "Face registered successfully! You can now use Face ID for seamless attendance.",
        );
        context.go("/");
      }
    }
    return false;
  }

  Future onShot() async {
    XFile? file = await _camSR.takePicture();
    imagePath = file?.path;
    final directory = await getExternalStorageDirectory();
    final imageData = File(imagePath!);
    imgSavedPath = "${directory?.path}/dp.jpg";
    final toImage = File(imgSavedPath!);
    toImage.writeAsBytes(imageData.readAsBytesSync());
    setState(() {
      pictureTaken = true;
    });
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      pictureTaken = false;
    });
    _start();
  }

  Widget getBodyWidget() {
    if (_initializing) return const Center(child: CircularProgressIndicator());
    if (pictureTaken) return ImageView(imagePath: imagePath);
    return CameraPreviewBody();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = getBodyWidget();

    return Scaffold(
      body: Stack(
        children: [
          body,
          CameraHeader(
            "Register User",
            onBackPressed: _onBackPressed,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
        onPressed: () => onCapture(context),
        child: Badge(
          label: Text(
            "$captureCount",
            style: const TextStyle(fontSize: 16),
          ),
          isLabelVisible: captureCount != 0,
          offset: const Offset(-120, -22),
          backgroundColor: Theme.of(context).colorScheme.primaryFixed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_rounded),
              SizedBox(width: 10),
              Text("Capture Face"),
            ],
          ),
        ),
      ),
    );
  }
}
