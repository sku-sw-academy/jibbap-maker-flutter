import 'package:flutter_splim/dto/UserDTO.dart';

class RecipeDTO {
  final int id; // Immutable
  final UserDTO userId; // Immutable
  final String name; // Immutable
  String? comment; // Mutable and nullable
  String? image; // Mutable and nullable
  bool status; // Mutable
  final String updated_at; // Immutable

  RecipeDTO({
    required this.id,
    required this.userId,
    required this.name,
    this.comment,
    this.image,
    required this.status,
    required this.updated_at,
  });

  factory RecipeDTO.fromJson(Map<String, dynamic> json) {
    return RecipeDTO(
      id: json['id'],
      userId: UserDTO.fromJson(json['id']),
      name: json['name'],
      comment: json['comment'],
      image: json['image'],
      status: json['status'],
      updated_at: json['modifyDate']
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userId' : userId.toJson(),
    'name' : name,
    'comment' : comment,
    'image' : image,
    'status' : status,
    'modifyDate' : updated_at
  };
}