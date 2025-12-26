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
  late TabController _tabController;
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        index = _tabController.index;
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
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                index == 0
                    ? SliverAppBar(
                        floating: true,
                        pinned: false,
                        snap: true,
                        backgroundColor: Colors.white,

                        // collapsedHeight:
                        //     kToolbarHeight + MediaQuery.of(context).padding.top,
                        // expandedHeight: kToolbarHeight,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.white,
                        // title: SafeArea(
                        //   child: PreferredSize(
                        //     preferredSize: Size.fromHeight(100),
                        //     child: buildSwitcher(),
                        //   ),
                        // ),
                        flexibleSpace: SafeArea(
                          bottom: false,
                          child: Center(child: buildSwitcher()),
                        ),
                      )
                    : SliverAppBar(
                        pinned: true,
                        floating: false,
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.white,
                        flexibleSpace: SafeArea(
                          child: Center(child: buildSwitcher()),
                        ),
                      ),
              ];
            },
            body: MediaQuery.removePadding(
              context: context,

              removeTop: true,
              removeBottom: true,
              child: TabBarView(
                controller: _tabController,
                children: [
                  UserListWidget(
                    users: users,
                    controller: usersScrollController,
                  ),
                  ChatHistoryWidget(
                    chatHistory: chatHistory,
                    controller: chatHistoryScrollController,
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
            isScrollable: false,
            controller: _tabController,
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
