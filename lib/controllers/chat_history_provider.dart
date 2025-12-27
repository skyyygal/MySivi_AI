import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_sivi_ai/controllers/user_provider.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';

class ChatHistoryController extends StateNotifier<List<ChatHistoryItem>> {
  final Ref ref;
  ChatHistoryController(this.ref) : super([]) {
    ref.listen<List<User>>(usersProvider, (prev, next) {
      if (next.isNotEmpty) generateChatHistory(next);
    });
  }

  Future<void> generateChatHistory(List<User> users) async {
    final apiMessages = await ChatService().fetchReceiverMessages();
    final random = Random();
    final senderMessages = [
      'I know what this is!',
      'Lets do it',
      'What are you up to?',
      'Check this out!',
      'Any updates?',
      'Okay, I\'ll wait for this',
    ];
    final shuffledUsers = users.toList()..shuffle();
    final unreadUsers = shuffledUsers.take(min(4, users.length)).toList();

    state = users.map((user) {
      final isSender = random.nextBool();
      final lastMsg = isSender
          ? ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch,
              message: senderMessages[random.nextInt(senderMessages.length)],
              senderName: 'You',
              type: MessageType.sender,
              timestamp: DateTime.now(),
            )
          : apiMessages[random.nextInt(apiMessages.length)];

      final now = DateTime.now();
      final timeType = random.nextInt(3);
      DateTime time;
      if (timeType == 0) {
        time = now.subtract(Duration(minutes: random.nextInt(59) + 1));
      } else if (timeType == 1) {
        time = now.subtract(Duration(hours: random.nextInt(12) + 1));
      } else {
        time = now.subtract(Duration(days: 1, hours: random.nextInt(24)));
      }

      final unreadCount = unreadUsers.contains(user)
          ? random.nextInt(3) + 1
          : 0;

      return ChatHistoryItem(
        user: user,
        lastMessage: lastMsg,
        time: time,
        unreadCount: unreadCount,
      );
    }).toList();
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryController, List<ChatHistoryItem>>(
      (ref) => ChatHistoryController(ref),
    );
