import 'package:flutter/material.dart';
import 'package:track_presence/getit.dart';
import 'package:track_presence/services/camera_service.dart';
import 'package:track_presence/services/face_detector_service.dart';
import 'package:track_presence/services/ml_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MLService _mlService = getIt<MLService>();
  final CameraService _cameraService = getIt<CameraService>();
  final FaceDetectorService _faceService = getIt<FaceDetectorService>();

  bool loading = false;
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    setState(() => loading = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _faceService.initialize();
    setState(() => loading = false);
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
