import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:vcare_attendance/db/databse_helper.dart';

// import 'package:face_attendance/db/databse_helper.dart';
import 'package:vcare_attendance/models/user_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// ignore: implementation_imports
import 'package:image/image.dart' as imglib;

import 'image_converter.dart';

int getRed(int color) => (color) & 0xff;
int getGreen(int color) => (color >> 8) & 0xff;
int getBlue(int color) => (color >> 16) & 0xff;

class MLService {
  late Interpreter _interpreter;
  double threshold = 0.5;
  List<int> inputShapList = [1, 112, 112, 3];
  int inputShapSize = 1 * 112 * 112 * 3;

  late List<int> _inputShape;
  late List<int> _outputShape;

  List<List> _predictedDataList = [];
  List<List> get predictedDataList => _predictedDataList;
  List<double> _predictedData = [];
  List get predictedData => _predictedData;

  Future initialize() async {
    // late Delegate delegate;
    try {
      // if (Platform.isAndroid) {
      //   delegate = GpuDelegateV2(
      //     options: GpuDelegateOptionsV2(
      //       isPrecisionLossAllowed: false,
      //       inferencePreference: TfLiteGpuInferenceUsage
      //           .TFLITE_GPU_INFERENCE_PREFERENCE_FAST_SINGLE_ANSWER,
      //       inferencePriority1: TfLiteGpuInferencePriority
      //           .TFLITE_GPU_INFERENCE_PRIORITY_MIN_LATENCY,
      //       inferencePriority2:
      //           TfLiteGpuInferencePriority.TFLITE_GPU_INFERENCE_PRIORITY_AUTO,
      //       inferencePriority3:
      //           TfLiteGpuInferencePriority.TFLITE_GPU_INFERENCE_PRIORITY_AUTO,
      //     ),
      //   );
      // } else if (Platform.isIOS) {
      //   delegate = GpuDelegate(
      //     options: GpuDelegateOptions(
      //         allowPrecisionLoss: true,
      //         waitType: TFLGpuDelegateWaitType.TFLGpuDelegateWaitTypeActive),
      //   );
      // }
      // var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      _interpreter.allocateTensors();
      var inputTensor = _interpreter.getInputTensor(0);
      _inputShape = inputTensor.shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      debugPrint("Model loaded. Input: $_inputShape, Output: $_outputShape");
      debugPrint('Model loaded Input type: ${inputTensor.type}');
      debugPrint(
          'Model loaded. Quantization params: ${inputTensor.params.toString()}');
    } catch (e) {
      debugPrint('Failed to load model.');
      debugPrint(e.toString());
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, Face? face) {
    if (face == null) throw Exception('Face is null');
    Float32List input = _preProcess(cameraImage, face);
    var output =
        List.filled(_outputShape[1], 0.0).reshape([1, _outputShape[1]]);
    debugPrint(
        "Data Input-shape: ${input.shape} :: Output-shape: ${output.shape}");
    debugPrint("Model loaded. Input: $_inputShape, Output: $_outputShape");

    _interpreter.run(input.reshape([1, 112, 112, 3]), output);
    output = output.reshape([192]);
    debugPrint(
        "After Data Input-shape: ${input.shape} :: Output-shape: ${output.shape}");
    _predictedData = List.from(output);
    _predictedDataList.add(_predictedData);
    return;
  }

  void addCaptures() {
    _predictedDataList.add(_predictedData);
  }

  void resetPredicted() {
    _predictedData = [];
    _predictedDataList = [];
  }

  Future<User?> predict() async {
    return _searchResult(_predictedData);
  }

  imglib.Image modealImage(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    return imglib.copyResizeCropSquare(croppedImage, size: 112);
  }

  Float32List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);
    return imageToByteListFloat32(img);
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(convertedImage,
        x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    return imglib.copyRotate(img, angle: -90);
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var buffer = Float32List(inputShapSize);
    int index = 0;

    for (int y = 0; y < 112; y++) {
      for (int x = 0; x < 112; x++) {
        final pixel = image.getPixelSafe(x, y);
        buffer[index++] = (pixel.r - 127.5) / 128;
        buffer[index++] = (pixel.g - 127.5) / 128;
        buffer[index++] = (pixel.b - 127.5) / 128;
      }
    }
    return buffer;
  }

  Future<User?> _searchResult(List predictedData) async {
    DB dbHelper = DB.instance;

    List<User> users = await dbHelper.queryAllUsers();
    double minDist = 999;
    double currDist = 0.0;
    User? predictedResult;

    print('users.length=> ${users.length}');

    for (User u in users) {
      currDist = _euclideanDistance(u.modelData, predictedData);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predictedResult = u;
      }
    }
    return predictedResult;
  }

  double _euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  /// double similarity = cosineSimilarity(storedEmbeddingsList, newEmbeddings);
  /// debugPrint("Face similarity score: $similarity");
  ///
  /// return similarity > 0.6717;
  double cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0, normA = 0, normB = 0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return normA == 0 || normB == 0
        ? 0
        : dotProduct / (sqrt(normA) * sqrt(normB));
  }

  void setPredictedData(value) {
    _predictedData = value;
  }

  void dispose() {
    _interpreter.close();
    _predictedData = [];
  }
}
