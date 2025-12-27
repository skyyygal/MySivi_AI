import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';

class ChatService {
  static const url = 'https://dummyjson.com/comments?limit=15';

  Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List comments = data['comments'];
      final userMap = <int, User>{};
      for (final comment in comments) {
        final userJson = comment['user'];
        final user = User.fromJson(userJson);
        userMap[user.id] = user;
      }
      return userMap.values.toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<List<ChatMessage>> fetchReceiverMessages() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List comments = data['comments'];
      return comments.map((e) => ChatMessage.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
