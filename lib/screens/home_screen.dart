import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';
import 'package:my_sivi_ai/widgets/chat_history.dart';
import 'package:my_sivi_ai/widgets/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int index = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  List<User> users = [];
  bool isLoadingUsers = true;
  List<ChatHistoryItem> chatHistory = [];
  bool isLoadingHistory = true;

  String? usersError;

  // late final ScrollController usersScrollController;
  // late final ScrollController chatHistoryScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        index = _tabController.index;
      });
    });

    // usersScrollController = ScrollController();
    // chatHistoryScrollController = ScrollController();

    fetchUsers();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _scrollController.dispose();
  }

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
      'Okay, I\'ll wait for this',
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
              onPressed: () => Navigator.pop(context),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: index == 0
            ? FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: Colors.indigoAccent,
                onPressed: addNewUser,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        body: NestedScrollView(
          headerSliverBuilder: (_, _) {
            return [
              SliverAppBar(
                pinned: index % 2 == 0 ? false : true,
                floating: index % 2 == 0 ? true : false,
                snap: index % 2 == 0 ? true : false,
                toolbarHeight: 40,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                title: Column(
                  children: [
                    Container(
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.grey.shade200,
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,

                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black45,
                        padding: EdgeInsets.all(2),
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        tabs: const [
                          Tab(text: "Users"),
                          Tab(text: "Chat History"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          controller: _scrollController,
          body: TabBarView(
            controller: _tabController,
            children: [
              UserListWidget(users: users),
              ChatHistoryWidget(chatHistory: chatHistory),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey.shade200,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,

        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        padding: EdgeInsets.all(2),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        tabs: const [
          Tab(text: "Users"),
          Tab(text: "Chat History"),
        ],
      ),
    );
  }
}
