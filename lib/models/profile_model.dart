class Profile {
  String userId;
  String cloudId;
  String name;
  String dateOfJoin;
  String? email;
  String? imgPath;
  String? department;
  String? designation;
  String? imgUrl;

  Profile({
    required this.cloudId,
    required this.userId,
    required this.name,
    required this.dateOfJoin,
    this.department,
    this.designation,
    this.email,
    this.imgPath,
    this.imgUrl,
  });

  static Profile fromMap(Map<String, dynamic> data) {
    return Profile(
      cloudId: data['cloud_id'],
      userId: data['user_id'],
      name: data['name'],
      email: data['eamil'],
      imgPath: data['img_path'],
      imgUrl: data['img_url'],
      dateOfJoin: data['date_of_join'],
      department: data['department'],
      designation: data['designation'],
    );
  }

  // TODO: make the api return not empty "department","designation"
  static Profile fromApiJson(Map<String, dynamic> data) {
    return Profile(
      cloudId: data['id'],
      userId: data['employee_id'],
      name: data['employee_name'],
      email: data['eamil'],
      imgPath: data['photo'],
      imgUrl: data['photo'],
      dateOfJoin: data['doj'],
      department: data['department'] == "" ? null : data['department'],
      designation: data['designation'] == "" ? null : data['designation'],
    );
  }

  toMap() {
    return {
      'user_id': userId,
      'cloud_id': cloudId,
      'name': name,
      'email': email,
      'img_path': imgPath,
      'img_url': imgUrl,
      'date_of_join': dateOfJoin,
      'department': department,
      'designation': designation,
    };
  }
}
