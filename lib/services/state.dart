import 'package:vcare_attendance/api/api.dart';
import 'package:vcare_attendance/db/profile_db.dart';
import 'package:vcare_attendance/models/profile_model.dart';

class AppState {
  Profile? profile;
  Profile? localProfile;

  List<String> department = [];

  Future<void> initProfile(String id) async {
    profile = await Api.getProfile(id);
    department = await Api.getDepartments();

    final pdb = ProfileDB.instance;
    final pro = await pdb.queryAllProfile();

    if (pro.isNotEmpty) {
      localProfile = pro[0];
    }
  }

  Future<void> fetchDepartments() async {
    department = await Api.getDepartments();
  }
}
