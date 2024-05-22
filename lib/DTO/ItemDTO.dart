import 'package:flutter_splim/DTO/CateogryDTO.dart';

class ItemCodeDTO {
  final String itemName;
  final int itemCode;
  final CategoryDTO category;
  final String? imagePath;

  ItemCodeDTO({
    required this.itemName,
    required this.itemCode,
    required this.category,
    this.imagePath,
  });

  // JSON 데이터를 ItemCodeDTO 객체로 변환하는 factory 메서드
  factory ItemCodeDTO.fromJson(Map<String, dynamic> json) {
    return ItemCodeDTO(
      itemName: json['item_name'],
      itemCode: json['item_code'],
      category: CategoryDTO.fromJson(json['category']),
      imagePath: json['imagePath'],
    );
  }
}