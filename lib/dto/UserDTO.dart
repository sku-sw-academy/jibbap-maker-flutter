class UserDTO{
  final int id;
  final String email;
  final String nickname;
  final String profile;
  final String password;
  final bool enabled;
  final bool push;
  final bool log;
  final String fcmtoken;

  UserDTO({required this.id, required this.email, required this.nickname, required this.profile, required this.enabled, required this.password,
  required this.push, required this.log, required this.fcmtoken});

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      password: json['password'],
      profile: json['profile'],
      enabled: json['enabled'],
      push: json['push'],
      log: json['log'],
      fcmtoken: json['fcmToken'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'email': email,
    'nickname': nickname,
    'password': password,
    'profile' : profile,
    'enabled' : enabled,
    'push' : push,
    'log' : log,
    'fcmToken' : fcmtoken,
  };

}