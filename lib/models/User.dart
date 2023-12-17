class User {
  String? id;
  String username;
  String password;
  String role;

  User(
      {this.id,
      required this.username,
      required this.password,
      required this.role});

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['_id'].toString(),
        username: map['username'],
        password: map['password'],
        role: map['role'],
      );

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'username': username,
      'password': password,
      'role': role,
    };
  }
}
