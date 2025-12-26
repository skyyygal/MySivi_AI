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

  List<User> users = [];
  bool isLoadingUsers = true;
  List<ChatHistoryItem> chatHistory = [];
  bool isLoadingHistory = true;

  String? usersError;

  late final ScrollController usersScrollController;
  late final ScrollController chatHistoryScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        index = _tabController.index;
      });
    });

    usersScrollController = ScrollController();
    chatHistoryScrollController = ScrollController();

    fetchUsers();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
        body: Column(
          children: [
            // Container(
            //   height: 40,
            //   margin: const EdgeInsets.symmetric(horizontal: 60),
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(30),
            //     color: Colors.grey.shade200,
            //   ),
            //   child: TabBar(
            //     controller: _tabController,
            //     indicatorSize: TabBarIndicatorSize.tab,
            //     dividerColor: Colors.transparent,

            //     labelColor: Colors.black,
            //     unselectedLabelColor: Colors.black45,
            //     padding: EdgeInsets.all(2),
            //     indicator: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.all(Radius.circular(20)),
            //     ),
            //     tabs: const [
            //       Tab(text: "Users"),
            //       Tab(text: "Chat History"),
            //     ],
            //   ),
            // ),

            // const SizedBox(height: 10),
            Expanded(
              child: NestedScrollView(
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: _tabController.index == 1,
                      floating: _tabController.index == 0,
                      snap: _tabController.index == 0,
                      automaticallyImplyLeading: false,

                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: index == 1 ? Colors.white : null,
                      toolbarHeight: 40,
                      title: buildTabBar(),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Users tab content
                    UserListWidget(users: users),
                    // ChatHistory tab content
                    ChatHistoryWidget(chatHistory: chatHistory),
                  ],
                ),
              ),
            ),
          ],
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

   /*  return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: index != 0,
                  floating: index == 0,
                  snap: index == 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  shadowColor: Colors.white,
                  flexibleSpace: SafeArea(
                    bottom: false,
                    child: Center(child: buildSwitcher()),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                UserListWidget(users: users),
                ChatHistoryWidget(chatHistory: chatHistory),
              ],
            ),
          ),
          floatingActionButton: index == 0
              ? FloatingActionButton(
                  shape: CircleBorder(),
                  backgroundColor: Colors.indigoAccent,
                  onPressed: addNewUser,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        ),
      ),
    );
  }

  Widget buildSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            // isScrollable: false,
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
  } */
// }



/* import 'dart:math';

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
 */