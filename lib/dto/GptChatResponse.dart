class GptChatResponse {
  final String title;
  final String content;
  final String imageUrl;
  GptChatResponse({required this.title, required this.content, required this.imageUrl});

  factory GptChatResponse.fromJson(Map<String, dynamic> json) {
    return GptChatResponse(
        title: json['title'],
        content: json['content'],
        imageUrl: json['imageUrl']
    );
  }
}