import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sivi_ai/controllers/user_provider.dart';
import 'package:my_sivi_ai/core/constants.dart';
import 'package:my_sivi_ai/core/utils.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/widgets/avatar.dart';

class UserListWidget extends ConsumerWidget {
  const UserListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider);
    return ListView.builder(
      // primary: false,
      key: PageStorageKey("userList"),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        final lastSeen = DateTime.now().subtract(Duration(minutes: index * 5));

        final isOnline = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ListTile(
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
                      border: isOnline
                          ? Border.all(color: whiteColor, width: 2)
                          : null,
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
              isOnline ? "Online" : getLastSeenTime(lastSeen),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ),
        );
      },
    );
  }
}
