import 'package:my_sivi_ai/models/chat_messages.dart';

class User {
  final int id;
  final String fullName;

  User({required this.id, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], fullName: json['fullName']);
  }

  String get initials {
    List<String> firstName = fullName.split(' ');
    return firstName.isNotEmpty ? firstName[0][0].toUpperCase() : '?';
  }
}

class ChatHistoryItem {
  final User user;
  final ChatMessage lastMessage;
  final DateTime time;
  final int unreadCount;

  ChatHistoryItem({
    required this.user,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
  });
}
