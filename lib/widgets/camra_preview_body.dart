import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:vcare_attendance/getit.dart';
import 'package:vcare_attendance/services/camera_service.dart';
import 'package:vcare_attendance/services/face_detector_service.dart';
import 'package:vcare_attendance/widgets/face_painter.dart';

class CameraPreviewBody extends StatelessWidget {
  CameraPreviewBody({super.key});

  final CameraService _camSR = getIt<CameraService>();
  final FaceDetectorService _faceSR = getIt<FaceDetectorService>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Transform.scale(
      scale: 1.0,
      child: AspectRatio(
        aspectRatio: MediaQuery.of(context).size.aspectRatio,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: SizedBox(
              width: width,
              height: width * _camSR.cameraController!.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreview(_camSR.cameraController!),
                  if (_faceSR.faceDetected)
                    CustomPaint(
                      painter: FacePainter(
                          face: _faceSR.faces[0],
                          imageSize: _camSR.getImageSize()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
