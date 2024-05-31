class AuthLoginResponse{
  final int id;
  final String accessToken;

  AuthLoginResponse({required this.id, required this.accessToken});

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponse(
      id: json['id'],
      accessToken: json['accessToken'],
    );
  }

  // toJson 메서드 추가 - JSON 변환을 위해
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accessToken': accessToken,
    };
  }

}