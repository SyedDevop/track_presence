import 'package:get_it/get_it.dart';
import 'package:track_presence/services/camera_service.dart';
import 'package:track_presence/services/face_detector_service.dart';
import 'package:track_presence/services/ml_service.dart';

final getIt = GetIt.instance;

void initServices() {
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
  getIt.registerLazySingleton<MLService>(() => MLService());
}
