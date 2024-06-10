import 'package:flutter_splim/dto/UserDTO.dart';

class RecipeDTO {
  final int id; // Immutable
  final UserDTO userId; // Immutable
  final String name;// Immutable
  final String description;
  String? comment; // Mutable and nullable
  String? image; // Mutable and nullable
  bool status; // Mutable
  final DateTime modifyDate;

  RecipeDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.comment,
    this.image,
    required this.status,
    required this.modifyDate,
  });

  factory RecipeDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDTO(
      id: json['id'],
      userId: UserDTO.fromJson(json['id']),
      name: json['name'],
      description: json['description'],
      comment: json['comment'],
      image: json['image'],
      status: json['status'],
      modifyDate: DateTime.parse(json['modifyDate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userId' : userId.toJson(),
    'name' : name,
    'description' : description,
    'comment' : comment,
    'image' : image,
    'status' : status,
    'modifyDate': modifyDate.toIso8601String(),
  };
}