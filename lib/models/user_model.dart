import 'dart:convert';

class User {
  String userId;
  List modelData;

  User({
    required this.userId,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      userId: user['user_id'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'user_id': userId,
      'model_data': jsonEncode(modelData),
    };
  }
}
