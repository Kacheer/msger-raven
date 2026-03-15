class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? username;
  final String? avatarUrl;
  final String? description;
  final int? gender;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.username,
    this.avatarUrl,
    this.description,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      description: json['description'],
      gender: json['gender'],
    );
  }

  String get displayName => '$firstName $lastName';
}
