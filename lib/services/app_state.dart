// TODO: Rename this to app after all the auth update to jwt state.
import 'package:vcare_attendance/utils/jwtToken.dart';

class AppStore {
  late JwtToken token;
  setToken(JwtToken t) {
    token = t;
  }
}
