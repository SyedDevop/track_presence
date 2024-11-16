import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class AppState {
  Profile? profile;
  Future<void> initProfile(String id) async {
    profile = await Api.getProfile(id);
  }
}
