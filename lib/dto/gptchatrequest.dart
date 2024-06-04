class GptChatRequest{
  final int id;
  final String thriftyItems;

  GptChatRequest({required this.id, required this.thriftyItems});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thriftyItems': thriftyItems,
    };
  }
}