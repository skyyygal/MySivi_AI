import 'package:flutter/material.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';

final bucket = PageStorageBucket();

class UserListWidget extends StatelessWidget {
  final List<User> users;
  final ScrollController controller;
  String getLastSeenTime(DateTime lastSeen) {
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inMinutes < 1) return 'Online';
    if (difference.inHours < 1) return '${difference.inMinutes} mins ago';
    if (difference.inDays < 1) return '${difference.inHours} hrs ago';
    return '${difference.inDays} days ago';
  }

  const UserListWidget({
    super.key,
    required this.users,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: bucket,

      child: ListView.builder(
        key: PageStorageKey(0),
        // controller: controller,
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];

          final lastSeen = DateTime.now().subtract(
            Duration(minutes: index * 5),
          );

          final isOnline = index % 2 == 0;
          return ListTile(
            leading: Stack(
              children: [
                Avatar(text: user.initials, gradient: indigoGradient),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : null,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: isOnline ? 2 : 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            title: Text(
              user.fullName,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    user: user,
                    status: isOnline
                        ? "Online"
                        : "Last seen ${getLastSeenTime(lastSeen)}",
                  ),
                ),
              );
            },

            subtitle: Text(
              isOnline ? "Online" : "Last seen ${getLastSeenTime(lastSeen)}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          );
        },
      ),
    );
  }
}
