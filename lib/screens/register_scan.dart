import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'package:track_presence/api/api.dart';
import 'package:track_presence/db/databse_helper.dart';
import 'package:track_presence/getit.dart';
import 'package:track_presence/models/profile_model.dart';
import 'package:track_presence/models/user_model.dart';
import 'package:track_presence/services/camera_service.dart';
import 'package:track_presence/services/face_detector_service.dart';
import 'package:track_presence/services/ml_service.dart';
import 'package:track_presence/widgets/cam_header.dart';
import 'package:track_presence/widgets/camra_preview_body.dart';
import 'package:track_presence/widgets/image_view.dart';

class RegisterScan extends StatefulWidget {
  const RegisterScan({super.key});

  @override
  State<RegisterScan> createState() => _RegisterScanState();
}

class _RegisterScanState extends State<RegisterScan> {
  final _userIdController = TextEditingController(text: '');
  Profile? _profile;
  final MLService _mlSR = getIt<MLService>();
  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String? imagePath;
  Face? faceDetected;

  bool _saving = false;
  bool pictureTaken = false;
  bool _initializing = false;
  bool _detectingFaces = false;
  bool _bottomSheetVisible = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _camSR.dispose();
    super.dispose();
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

  Future onCapture(BuildContext context) async {
    bool faceDetected = await onShot();
    if (faceDetected) {
      Scaffold.of(context).showBottomSheet((context) => addUserSheet(context))
        ..closed.whenComplete(_reload);
    }
  }

  Future<bool> onShot() async {
    if (faceDetected == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );
      return false;
    } else {
      _saving = true;
      XFile? file = await _camSR.takePicture();
      imagePath = file?.path;
      final directory = await getExternalStorageDirectory();
      final imageData = File(imagePath!);
      final toImage = File("${directory?.path}/dp.jpg");
      toImage.writeAsBytes(imageData.readAsBytesSync());
      setState(() {
        _bottomSheetVisible = true;
        pictureTaken = true;
      });
      return true;
    }
  }

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    setState(() {
      _bottomSheetVisible = false;
      pictureTaken = false;
    });
    _start();
  }

  _addUser(BuildContext context) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _initializing = true;
    });
    final newProfile = await Api.getProfile(_userIdController.text);

    if (newProfile == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('User Not Found Try Again'),
          );
        },
      );
    } else {
      _profile = newProfile;
      if (_profile?.imgPath == "" || _profile?.imgPath == null) {
        _profile?.imgPath = imagePath!;
      }
      Scaffold.of(context).showBottomSheet(
        (context) => conformUserSheet(context),
      );
    }
    setState(() => _initializing = false);
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_bottomSheetVisible
          ? Builder(builder: (context) {
              return InkWell(
                onTap: () => onCapture(context),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue[200],
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CAPTURE',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.camera_alt, color: Colors.white)
                    ],
                  ),
                ),
              );
            })
          : Container(),
    );
  }

  conformUserSheet(BuildContext content) {
    return Builder(builder: (context) {
      return ConformUser(
          profile: _profile,
          handelBack: () {
            Scaffold.of(context)
                .showBottomSheet((context) => addUserSheet(context));
            _userIdController.clear();
          },
          handelConform: () async {
            DB db = DB.instance;
            List predictedData = _mlSR.predictedData;
            print("Data => $predictedData");
            User userToSave = User(
              userId: _profile!.userId,
              userName: _profile!.name,
              modelData: predictedData,
            );
            await db.insert(userToSave);
            _mlSR.setPredictedData([]);
            context.go("/");
          });
    });
  }

  addUserSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          TextField(
            controller: _userIdController,
            autofocus: true,
            autocorrect: false,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(labelText: "User Id"),
          ),
          const SizedBox(height: 50),
          TextButton.icon(
            onPressed: _initializing ? null : () => _addUser(context),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text("Add"),
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

class ProfileText extends StatelessWidget {
  const ProfileText(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class ConformUser extends StatelessWidget {
  const ConformUser(
      {super.key,
      this.profile,
      required this.handelBack,
      required this.handelConform});

  final Profile? profile;
  final void Function() handelBack;
  final void Function() handelConform;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(50), // Adjust the radius as needed
              child: profile?.imgPath == null
                  ? const Icon(
                      Icons.account_circle_rounded,
                      size: 75,
                    )
                  : Image.file(
                      File(profile!.imgPath!),
                      fit: BoxFit
                          .fitWidth, // Adjust the fit to cover the entire area
                      width: 100, // Adjust width
                      height: 100, // Adjust height
                    ),
            ),
          ),
          ProfileText("Name            : ${profile?.name}"),
          ProfileText("Email             : ${profile?.email ?? "Not Found"}"),
          ProfileText("User Id           : ${profile?.userId}"),
          ProfileText(
              "department   : ${profile?.department ?? "Not Assigned"}"),
          ProfileText(
              "designation   : ${profile?.designation ?? "Not Assigned"}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                  onPressed: handelBack,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent,
                  ),
                  label: const Text(
                    "Back",
                    style: TextStyle(color: Colors.redAccent),
                  )),
              TextButton.icon(
                  onPressed: handelConform,
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Colors.tealAccent,
                  ),
                  label: const Text(
                    "Conform",
                    style: TextStyle(color: Colors.tealAccent),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
