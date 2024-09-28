import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraService {
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;

  InputImageRotation? _cameraRotation;
  InputImageRotation? get cameraRotation => _cameraRotation;

  String? _imagePath;
  String? get imagePath => _imagePath;

  CameraLensDirection? _currentLens;

  Future<void> initialize({
    CameraLensDirection lens = CameraLensDirection.front,
  }) async {
    if (_cameraController != null) return;
    CameraDescription description = await _getCamera(lens);
    await _setupCameraController(description: description);
    _cameraRotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );
  }

  Future<CameraDescription> _getCamera(CameraLensDirection lens) async {
    List<CameraDescription> cameras = await availableCameras();
    _currentLens = lens;
    return cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == lens,
    );
  }

  Future _setupCameraController({
    required CameraDescription description,
  }) async {
    _cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _cameraController?.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> toggleCamera() async {
    stop();
    _cameraController = null;
    if (_currentLens == CameraLensDirection.front) {
      initialize(lens: CameraLensDirection.back);
    } else if (_currentLens == CameraLensDirection.back) {
      initialize(lens: CameraLensDirection.front);
    }
  }

  Future<XFile?> takePicture() async {
    assert(_cameraController != null, 'Camera controller not initialized');
    await _cameraController?.stopImageStream();
    XFile? file = await _cameraController?.takePicture();
    _cameraController?.takePicture();
    _imagePath = file?.path;
    return file;
  }

  Future<void> stop() async {
    await _cameraController?.stopImageStream();
  }

  Size getImageSize() {
    assert(_cameraController != null, 'Camera controller not initialized');
    assert(
        _cameraController!.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController!.value.previewSize!.height,
      _cameraController!.value.previewSize!.width,
    );
  }

  dispose() async {
    await _cameraController?.dispose();
    _cameraController = null;
  }
}
