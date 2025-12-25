import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/user_models.dart';

class UserListWidget extends StatelessWidget {
  final List<User> users;
  final ScrollController scrollController;
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
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        final lastSeen = DateTime.now().subtract(Duration(minutes: index * 5));

        final isOnline = index % 2 == 0;
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(child: Text(user.initials)),
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

          title: Text(user.fullName),

          subtitle: Text(
            isOnline ? "Online" : "Last seen ${getLastSeenTime(lastSeen)}",
          ),
        );
      },
    );
  }
}
   // ListView.builder(
              //   primary: true,
              //   itemCount: users.length,
              //   itemBuilder: (context, index) {
              //     final user = users[index];
              //     return ListTile(
              //       leading: CircleAvatar(child: Text(user.initials)),
              //       title: Text(user.fullName),

              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => ChatScreen(user: user),
              //           ),
              //         );
              //       },
              //     );
              //   },
              // ),