class AuthLoginRequest{
  final String email;
  final String password;

  AuthLoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}