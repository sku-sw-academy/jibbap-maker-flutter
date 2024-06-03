class AuthLoginResponse{
  final int id;
  final String accessToken;
  final String refreshToken;

  AuthLoginResponse({required this.id, required this.accessToken, required this.refreshToken});

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponse(
      id: json['id'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  // toJson 메서드 추가 - JSON 변환을 위해
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accessToken': accessToken,
      'refreshToken' : refreshToken
    };
  }

}