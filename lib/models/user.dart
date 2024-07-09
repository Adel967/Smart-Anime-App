

final String tableUser = 'user';

class UserFields {
  static final List<String> values = [
    /// Add all fields
     id,email, time
  ];

  static final String id = 'id';
  static final String email = 'email';
  static final String time = 'time';
}

class User {
  final String email;
  final DateTime createdTime;


  User({required this.email,required this.createdTime});

  static User fromJson(Map<String, Object?> json) => User(
    email: json[UserFields.email] as String,
    createdTime: DateTime.parse(json[UserFields.time] as String),
  );

  Map<String, Object?> toJson() => {
    UserFields.email: email,
    UserFields.time: createdTime.toIso8601String(),
  };

}