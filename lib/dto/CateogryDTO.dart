class CategoryDTO {
  final String categoryName;
  final int categoryCode;

  CategoryDTO({
    required this.categoryName,
    required this.categoryCode,
  });

  // JSON 데이터를 CategoryDTO 객체로 변환하는 factory 메서드
  factory CategoryDTO.fromJson(Map<String, dynamic> json) {
    return CategoryDTO(
      categoryName: json['categoryName'],
      categoryCode: json['categoryCode'],
    );
  }
}