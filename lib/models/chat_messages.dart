enum MessageType { sender, receiver }

class ChatMessage {
  final int id;
  final String message;
  final String senderName;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderName,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      message: json['body'] ?? '',
      senderName: json['user']?['username'] ?? 'Receiver',
      type: MessageType.receiver,
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  factory ChatMessage.sender({required String message}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      senderName: 'You',
      type: MessageType.sender,
      timestamp: DateTime.now(),
    );
  }

  String get initials {
    if (type == MessageType.sender) return 'Y';
    if (senderName.isEmpty || senderName == 'Receiver') return 'R';
    return senderName[0].toUpperCase();
  }
}
