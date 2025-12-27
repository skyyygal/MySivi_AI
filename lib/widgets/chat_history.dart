import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sivi_ai/controllers/chat_history_provider.dart';
import 'package:my_sivi_ai/core/constants.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';

class ChatHistoryWidget extends ConsumerWidget {
  const ChatHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatHistory = ref.watch(chatHistoryProvider);

    return PrimaryScrollController(
      controller: ScrollController(),
      child: ListView.builder(
        key: PageStorageKey("chatHistory"),
        itemCount: chatHistory.length,
        itemBuilder: (_, index) {
          final item = chatHistory[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListTile(
              leading: Avatar(
                gradient: greenGradient,
                text: item.user.fullName.isNotEmpty
                    ? item.user.fullName[0].toUpperCase()
                    : '',
              ),

              title: Text(
                item.user.fullName,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item.lastMessage.message,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(user: item.user),
                  ),
                );
              },
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatChatTime(item.time),
                    style: const TextStyle(fontSize: 12, color: blackColor),
                  ),
                  if (item.unreadCount > 2)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${item.unreadCount}',
                        style: const TextStyle(color: whiteColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
