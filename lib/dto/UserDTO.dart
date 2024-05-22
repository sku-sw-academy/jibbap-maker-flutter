class UserDTO{
  final int id;
  final String email;
  final String nickname;
  final String profile;
  final bool enabled;
  final bool push;
  final bool log;
  final String fcm_token;
  final String access_token;
  final String refresh_token;

  UserDTO({required this.id, required this.email, required this.nickname, required this.profile, required this.enabled,
  required this.push, required this.log, required this.fcm_token, required this.access_token, required this.refresh_token});

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      email: json['email'],
      nickname: json['nickname'],
      profile: json['profile'],
      enabled: json['enabled'],
      push: json['push'],
      log: json['log'],
      fcm_token: json['fcm_token'],
      access_token: json['access_token'],
      refresh_token: json['refresh_token']
    );
  }

}