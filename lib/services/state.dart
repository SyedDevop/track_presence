import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/db/profile_db.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class AppState {
  Profile? profile;
  Profile? localProfile;
  Future<void> initProfile(String id) async {
    profile = await Api.getProfile(id);

    final pdb = ProfileDB.instance;
    final pro = await pdb.queryAllProfile();

    if (pro.isNotEmpty) {
      localProfile = pro[0];
    }
  }
}
