import 'package:flutter_splim/dto/CateogryDTO.dart';

class ItemDTO {
  final String itemName;
  final int itemCode;
  final CategoryDTO category;
  final String? imagePath;
  final int count;

  ItemDTO({
    required this.itemName,
    required this.itemCode,
    required this.category,
    this.imagePath,
    required this.count
  });

  // JSON 데이터를 ItemCodeDTO 객체로 변환하는 factory 메서드
  factory ItemDTO.fromJson(Map<String, dynamic> json) {
    return ItemDTO(
      itemName: json['item_name'],
      itemCode: json['item_code'],
      category: CategoryDTO.fromJson(json['category']),
      imagePath: json['imagePath'],
      count: json['count']
    );
  }

  Map<String, dynamic> toJson() => {
    'item_name' : itemName,
    'item_code' : itemCode,
    'category' : category.toJson(),
    'imagePath' : imagePath,
    'count' : count,
  };
}