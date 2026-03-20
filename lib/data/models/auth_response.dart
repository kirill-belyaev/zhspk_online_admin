class AuthResponse {
  final bool isValid;
  final String? token;

  AuthResponse({
    required this.isValid,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      isValid: json['is_valid'] ?? false,
      token: json['token'],
    );
  }
}