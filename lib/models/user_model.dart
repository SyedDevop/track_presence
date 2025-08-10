import 'dart:convert';

class User {
  String userId;
  String userName;
  List modelData;

  User({
    required this.userId,
    required this.userName,
    required this.modelData,
  });

  Map<String, String> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'model_data': jsonEncode(modelData),
    };
  }

  static User fromMap(Map<String, dynamic> user) {
    return User(
      userId: user['user_id'],
      userName: user['user_name'],
      modelData: jsonDecode(user['model_data']),
    );
  }
}
