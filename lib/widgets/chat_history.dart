import 'package:flutter/material.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';

class ChatHistoryWidget extends StatelessWidget {
  final List<ChatHistoryItem> chatHistory;
  // final ScrollController controller;

  const ChatHistoryWidget({
    super.key,
    required this.chatHistory,
    // required this.controller,
  });
  String formatChatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // key: key,
      key: PageStorageKey("chatHistory"),
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        final item = chatHistory[index];

        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(user: item.user)),
              );
            },
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatChatTime(item.time),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
