enum MessageType { sender, receiver }

class ChatMessage {
  final int id;
  final String message;
  final String senderName;
  final MessageType type;

  ChatMessage({
    required this.id,
    required this.message,
    required this.senderName,
    required this.type,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      message: json['body'] ?? '',
      senderName: json['user']?['username'] ?? 'Receiver',
      type: MessageType.receiver,
    );
  }
  factory ChatMessage.sender({required String message}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      senderName: 'You',
      type: MessageType.sender,
    );
  }

  String get initials {
    if (type == MessageType.sender) {
      return 'Y';
    }
    if (senderName.isEmpty || senderName == 'Receiver') {
      return 'R';
    }

    return senderName[0].toUpperCase();
  }
}
