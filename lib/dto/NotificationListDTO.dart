import 'package:flutter_splim/dto/UserDTO.dart';

class NotificationListDTO {
  final int id;
  final String title;
  final String body;
  final String modifyDate;
  final UserDTO userDTO;

  NotificationListDTO({
    required this.id,
    required this.title,
    required this.body,
    required this.modifyDate,
    required this.userDTO,
  });

  factory NotificationListDTO.fromJson(Map<String, dynamic> json) {
    return NotificationListDTO(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      modifyDate: json['modifyDate'],
      userDTO: UserDTO.fromJson(json['userDTO']),
    );
  }
}