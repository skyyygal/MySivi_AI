import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';
import 'package:my_sivi_ai/widgets/chat_history.dart';
import 'package:my_sivi_ai/widgets/tab_item.dart';
import 'package:my_sivi_ai/widgets/user.dart';

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
      'I know what this is!',
      'Lets do it',
      'What are you up to?',
      'Check this out!',
      'Any updates?',
      'Okay, i\'ll wait for this',
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
                timestamp: DateTime.now().subtract(Duration(minutes: 1 * 2)),
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
                      // pinned: true,
                      // floating: false,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      automaticallyImplyLeading: false,
                      title: buildSwitcher(),
                    ),
            ];
          },
          body: Container(
            color: Colors.white,
            child: TabBarView(
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
        ),

        floatingActionButton: index == 0
            ? FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: Colors.indigoAccent,
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  addNewUser();
                },
              )
            : null,
      ),
    );
  }

  Widget buildSwitcher() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 60),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.shade200,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: TabBar(
            controller: tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black45,
            tabs: const [
              TabItem(title: "User"),
              TabItem(title: "Chat History"),
            ],
          ),
        ),
      ),
    );
  }
}
