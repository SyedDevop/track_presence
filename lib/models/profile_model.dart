class Profile {
  String userId;
  String name;
  String? email;
  String? imgPath;
  String deptartment;
  String designation;

  Profile({
    required this.userId,
    required this.name,
    required this.deptartment,
    required this.designation,
    this.email,
    this.imgPath,
  });

  static Profile fromMap(Map<String, dynamic> data) {
    return Profile(
      userId: data['user_id'],
      name: data['name'],
      email: data['eamil'],
      imgPath: data['img_path'],
      deptartment: data['deptartment'],
      designation: data['designation'],
    );
  }

  toMap() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'img_path': imgPath,
      'deptartment': deptartment,
      'designation': designation,
    };
  }
}
