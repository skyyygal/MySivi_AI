import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';
import 'package:my_sivi_ai/widgets/chat_history.dart';
import 'package:my_sivi_ai/widgets/tab_item.dart';
import 'package:my_sivi_ai/widgets/user_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int index = 0;
  late TabController tabController;
  List<User> users = [];
  bool isLoadingUsers = true;
  List<ChatHistoryItem> chatHistory = [];
  bool isLoadingHistory = true;

  String? usersError;
  late final ScrollController usersScrollController;
  late final ScrollController chatHistoryScrollController;
  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await ChatService().fetchUsers();
      setState(() {
        users = fetchedUsers;
        isLoadingUsers = false;
      });
      generateChatHistory();
    } catch (e) {
      setState(() {
        usersError = 'Failed to load users';
        isLoadingUsers = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        index = tabController.index;
      });
    });
    usersScrollController = ScrollController();
    chatHistoryScrollController = ScrollController();
  }

  Future<void> generateChatHistory() async {
    if (users.isEmpty) return;

    setState(() {
      isLoadingHistory = true;
    });

    final random = Random();
    final senderMessages = [
      'Hey!',
      'How are you?',
      'What are you up to?',
      'Check this out!',
      'Any updates?',
    ];

    try {
      final apiMessages = await ChatService().fetchReceiverMessages();
      List<ChatHistoryItem> history = [];

      for (var user in users) {
        final isSender = random.nextBool();

        final lastMsg = isSender
            ? ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch,
                message: senderMessages[random.nextInt(senderMessages.length)],
                senderName: 'You',
                type: MessageType.sender,
              )
            : apiMessages[random.nextInt(apiMessages.length)];

        final time = DateTime.now().subtract(
          Duration(minutes: random.nextInt(60)),
        );
        final unreadCount = random.nextInt(5);

        history.add(
          ChatHistoryItem(
            user: user,
            lastMessage: lastMsg,
            time: time,
            unreadCount: unreadCount,
          ),
        );
      }

      setState(() {
        chatHistory = history;
        isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  void addNewUser() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New User"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Enter Full name'),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final newUser = User(
                    id: DateTime.now().millisecondsSinceEpoch,
                    fullName: name,
                  );
                  setState(() {
                    users.add(newUser);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('User "$name" added')));
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              index == 0
                  ? SliverAppBar(
                      floating: true,
                      snap: true,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      title: buildSwitcher(),
                    )
                  : SliverAppBar(
                      pinned: true,
                      floating: false,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      title: buildSwitcher(),
                    ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              UserListWidget(
                users: users,
                scrollController: usersScrollController,
              ),
              ChatHistoryWidget(
                chatHistory: chatHistory,
                users: users,
                scrollController: chatHistoryScrollController,
              ),
            ],
          ),
        ),

        floatingActionButton: index == 0
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {
                  addNewUser();
                },
              )
            : null,
      ),
    );
  }

  Widget buildSwitcher() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
      ),
      child: TabBar(
        controller: tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        tabs: const [
          TabItem(title: "User List"),
          TabItem(title: "Chat History"),
        ],
      ),
    );
  }
}
