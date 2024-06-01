import 'package:flutter_splim/dto/ItemDTO.dart';
import 'package:flutter_splim/dto/UserDTO.dart';

class PreferDTO{
  final int id;
  final ItemDTO item;
  final UserDTO user;
  late int prefer;

  PreferDTO({required this.id, required this.item, required this.user, required this.prefer});

  factory PreferDTO.fromJson(Map<String, dynamic> json) {
    return PreferDTO(
      id: json['id'],
      item: ItemDTO.fromJson(json['item']),
      user: UserDTO.fromJson(json['user']),
      prefer: json['prefer']
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'item' : item.toJson(),
    'user' : user.toJson(),
    'prefer' : prefer
  };

}