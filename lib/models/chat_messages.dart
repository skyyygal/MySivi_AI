class ChatMessage {
  final int id;
  final String message;
  final String senderName;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['body'],
      senderName: json['user']['fullName'],
    );
  }

  String get initials {
    final parts = senderName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return senderName[0];
  }
}
