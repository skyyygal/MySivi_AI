import 'package:flutter/material.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';

class ChatHistoryWidget extends StatelessWidget {
  final List<ChatHistoryItem> chatHistory;

  const ChatHistoryWidget({super.key, required this.chatHistory});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey('chat_history_tab'),
      itemCount: chatHistory.length,
      itemBuilder: (context, index) {
        final item = chatHistory[index];
        final minsAgo = DateTime.now().difference(item.time).inMinutes;

        return ListTile(
          leading: Avatar(
            gradient: greenGradient,
            text: item.user.fullName.isNotEmpty
                ? item.user.fullName[0].toUpperCase()
                : '',
          ),

          title: Text(item.user.fullName),
          subtitle: Text(
            item.lastMessage.message,
            overflow: TextOverflow.ellipsis,
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
                '$minsAgo mins ago',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              if (item.unreadCount > 0)
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
        );
      },
    );
  }
}
