class Profile {
  String userId;
  String name;
  String? email;
  String? imgPath;
  String? department;
  String? designation;

  Profile({
    required this.userId,
    required this.name,
    this.department,
    this.designation,
    this.email,
    this.imgPath,
  });

  static Profile fromMap(Map<String, dynamic> data) {
    return Profile(
      userId: data['user_id'],
      name: data['name'],
      email: data['eamil'],
      imgPath: data['img_path'],
      department: data['deptartment'],
      designation: data['designation'],
    );
  }

  // TODO: make the api return not empty "department","designation"
  static Profile fromApiJson(Map<String, dynamic> data) {
    return Profile(
      userId: data['employee_id'],
      name: data['employee_name'],
      email: data['eamil'],
      imgPath: data['photo'],
      department: data['department'] == "" ? null : data['department'],
      designation: data['designation'] == "" ? null : data['designation'],
    );
  }

  toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'img_path': imgPath,
      'deptartment': department,
      'designation': designation,
    };
  }
}
