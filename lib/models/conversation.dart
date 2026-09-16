class Message {
  final String role;
  final String content;
  Message(this.role, this.content);
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(json['role'] as String, json['content'] as String);
}

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;
  Conversation({required this.id, required this.title, List<Message>? messages})
    : messages = messages ?? [];
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json['id'],
    title: json['title'],
    messages: (json['messages'] as List)
        .map((m) => Message.fromJson(Map<String, dynamic>.from(m)))
        .toList(),
  );
}
