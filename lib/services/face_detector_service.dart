import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;
  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;
  bool get faceDetected => _faces.isNotEmpty;

  void initialize() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableContours: true,
        enableClassification: false,
      ),
    );
  }

  Future<void> detectFacesFromPath(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    _faces = await _faceDetector.processImage(inputImage);
  }

  ///for new version
  Future<void> detectFacesFromCam(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    final plane = image.planes.first;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return;
    }

    final img = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format,
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );

    _faces = await _faceDetector.processImage(img);
    // _faces = await _meshDetector.processImage(img);
  }

  dispose() {
    _faceDetector.close();
  }
}
