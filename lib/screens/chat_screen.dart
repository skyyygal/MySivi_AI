import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sivi_ai/controllers/message_controller.dart';
import 'package:my_sivi_ai/core/constants.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/dictionary_service.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';
import 'package:my_sivi_ai/widgets/message_text.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final User user;
  final String? status;

  const ChatScreen({super.key, required this.user, this.status});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).loadChatConversation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
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
      body: messages.isEmpty
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
