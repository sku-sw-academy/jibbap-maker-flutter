class UserDTO{
  final int id;
  final String email;
  late String nickname;
  String? profile;
  late String password;
  late bool enabled;
  late bool push;
  late bool log;
  String? fcmtoken;

  UserDTO({required this.id, required this.email, required this.nickname, this.profile, required this.enabled, required this.password,
  required this.push, required this.log, this.fcmtoken});

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