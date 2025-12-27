import 'dart:math';

import 'package:flutter_riverpod/legacy.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/services/chat_service.dart';

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController() : super([]);

  final List<String> senderMessages = [
    'The project is on track, all tasks are progressing.',
    'Have you reviewed the latest report?',
    'Please update me on the project status.',
    'Can we schedule a meeting for tomorrow?',
    'Thank you.',
    'I will follow up on this by end of day.',
    'Sure',
    'Tomorrow works fine for a meeting.',
    'I will send you the requested documents shortly.',
    'You’re welcome!',
    'Let me know if you need anything else.',
  ];

  Future<void> loadChatConversation() async {
    final random = Random();
    state = [];

    try {
      final apiMessages = await ChatService().fetchReceiverMessages();
      DateTime baseTime = DateTime.now().subtract(const Duration(minutes: 10));

      List<ChatMessage> loaded = [];

      for (int i = 0; i < 5; i++) {
        // Sender message
        final senderMsg = ChatMessage.sender(
          message: senderMessages[random.nextInt(senderMessages.length)],
        ).copyWith(timestamp: baseTime.add(Duration(minutes: i * 2)));
        loaded.add(senderMsg);

        // Receiver message
        final receiverMsg = apiMessages[i % apiMessages.length];
        loaded.add(
          ChatMessage(
            id: receiverMsg.id,
            message: receiverMsg.message,
            senderName: receiverMsg.senderName,
            type: MessageType.receiver,
            timestamp: baseTime.add(Duration(minutes: i * 2 + 1)),
          ),
        );
      }

      state = loaded;
    } catch (_) {}
  }

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
  }
}

final chatProvider = StateNotifierProvider<ChatController, List<ChatMessage>>(
  (ref) => ChatController(),
);
