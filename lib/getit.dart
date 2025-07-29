import 'package:get_it/get_it.dart';
import 'package:vcare_attendance/services/app_state.dart';
import 'package:vcare_attendance/services/camera_service.dart';
import 'package:vcare_attendance/services/face_detector_service.dart';
import 'package:vcare_attendance/services/ml_service.dart';
import 'package:vcare_attendance/services/track_service.dart';

final getIt = GetIt.instance;

void initServices() {
  getIt.registerLazySingleton<CameraService>(() => CameraService());
  getIt.registerLazySingleton<FaceDetectorService>(() => FaceDetectorService());
  getIt.registerLazySingleton<MLService>(() => MLService());
  getIt.registerLazySingleton<AppStore>(() => AppStore());
  getIt.registerLazySingleton<TrackingService>(() => TrackingService());
}
