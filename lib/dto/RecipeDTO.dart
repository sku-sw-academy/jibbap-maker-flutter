import 'package:flutter_splim/dto/UserDTO.dart';

class RecipeDTO {
  final int id; // Immutable
  final UserDTO userDTO; // Immutable
  final String title;// Immutable
  final String content;
  String? comment; // Mutable and nullable
  String? image; // Mutable and nullable
  bool status; // Mutable
  bool deletedAt;
  final DateTime modifyDate;

  RecipeDTO({
    required this.id,
    required this.userDTO,
    required this.title,
    required this.content,
    this.comment,
    this.image,
    required this.status,
    required this.modifyDate,
    required this.deletedAt
  });

  factory RecipeDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDTO(
      id: json['id'],
      userDTO: UserDTO.fromJson(json['userDTO']),
      title: json['title'],
      content: json['content'],
      comment: json['comment'],
      image: json['image'],
      status: json['status'],
      modifyDate: DateTime.parse(json['modifyDate']),
      deletedAt: json['deletedAt']
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userDTO': userDTO.toJson(),
    'title' : title,
    'content' : content,
    'comment' : comment,
    'image' : image,
    'status' : status,
    'modifyDate': modifyDate.toIso8601String(),
    'deletedAt' : deletedAt
  };
}