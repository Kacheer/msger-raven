class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? username;
  final String? deviceId;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.username,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    if (username != null) 'username': username,
    if (deviceId != null) 'deviceId': deviceId,
  };
}

class LoginRequest {
  final String email;
  final String password;
  final String? deviceId;

  LoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    if (deviceId != null) 'deviceId': deviceId,
  };
}

class AuthResponse {
  final String? token;
  final String? refreshToken;
  final String? userId;
  final String? email;
  final String? firstName;
  final String? lastName;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.userId,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
      email: json['email'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }
}
