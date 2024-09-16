import 'dart:convert';

class User {
  String name;
  List modelData;

  User({
    required this.name,
    required this.modelData,
  });

  static User fromMap(Map<String, dynamic> user) {
    return User(
      name: user['user'],
      modelData: jsonDecode(user['model_data']),
    );
  }

  toMap() {
    return {
      'user': name,
      'model_data': jsonEncode(modelData),
    };
  }
}
