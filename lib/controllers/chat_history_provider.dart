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

      return ChatHistoryItem(
        user: user,
        lastMessage: lastMsg,
        time: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
        unreadCount: random.nextInt(4),
      );
    }).toList();
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryController, List<ChatHistoryItem>>(
      (ref) => ChatHistoryController(ref),
    );
