import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';
import 'package:my_sivi_ai/services/dictionary_service.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';
import 'package:my_sivi_ai/widgets/message_text.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  final String? status;

  const ChatScreen({super.key, required this.user, this.status});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  bool isLoading = true;

  final List<String> senderMessages = [
    'The project is on track, all tasks are progressing.',
    'Have you reviewed the latest report?',
    'Please update me on the project status.',
    'Can we schedule a meeting for tomorrow?',
    'Thank you.',
    'I will follow up on this by end of day.',
    'Sure',

    ' tomorrow works fine for a meeting.',
    'I will send you the requested documents shortly.',
    'You’re welcome!',
    ' Let me know if you need anything else.',
  ];

  @override
  void initState() {
    super.initState();
    loadChatConversation();
  }

  Future<void> loadChatConversation() async {
    final random = Random();
    messages.clear();

    try {
      final apiMessages = await ChatService().fetchReceiverMessages();
      DateTime baseTime = DateTime.now().subtract(const Duration(minutes: 10));

      final firstReceiverMsg = apiMessages[0];
      messages.add(
        ChatMessage(
          id: firstReceiverMsg.id,
          message: firstReceiverMsg.message,
          senderName: firstReceiverMsg.senderName,
          type: MessageType.receiver,
          timestamp: baseTime,
        ),
      );

      for (int i = 1; i < 5; i++) {
        messages.add(
          ChatMessage.sender(
            message: senderMessages[random.nextInt(senderMessages.length)],
          ),
        );

        final receiverMsg = apiMessages[i % apiMessages.length];
        messages.add(
          ChatMessage(
            id: receiverMsg.id,
            message: receiverMsg.message,
            senderName: receiverMsg.senderName,
            type: MessageType.receiver,
            timestamp: baseTime.add(Duration(minutes: i * 2)),
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Avatar(
              gradient: indigoGradient,
              text: widget.user.initials,
            ),
            title: Text(widget.user.fullName),
            subtitle: Text(
              widget.status ?? "Online",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isSender = msg.type == MessageType.sender;

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Column(
                    crossAxisAlignment: isSender
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isSender)
                            Avatar(
                              text: msg.initials,
                              gradient: indigoGradient,
                            ),

                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.55,
                            ),
                            decoration: BoxDecoration(
                              color: isSender
                                  ? Colors.indigoAccent
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: MessageText(
                              message: msg.message,
                              onWordLongPress: (word) {
                                showWordMeaningBottomSheet(context, word);
                              },
                              isSender: isSender,
                            ),
                          ),

                          if (isSender)
                            Avatar(text: msg.initials, gradient: pinkGradient),
                          const SizedBox(height: 4),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Padding(
                        padding: EdgeInsets.only(
                          left: isSender ? 0 : 60,
                          right: isSender ? 60 : 0,
                        ),
                        child: Text(
                          formatTime(msg.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

void showWordMeaningBottomSheet(BuildContext context, String word) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return FutureBuilder<String>(
        future: fetchMeaning(word),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(snapshot.data ?? 'No meaning found'),
              ],
            ),
          );
        },
      );
    },
  );
}
