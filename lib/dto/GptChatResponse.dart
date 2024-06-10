class GptChatResponse {
  final String title;
  final String content;

  GptChatResponse({required this.title, required this.content});

  factory GptChatResponse.fromJson(Map<String, dynamic> json) {
    return GptChatResponse(
        title: json['title'],
        content: json['content']
    );
  }
}