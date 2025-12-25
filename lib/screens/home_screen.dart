import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/screens/chat_screen.dart';
import 'package:my_sivi_ai/services/chat_service.dart';
import 'package:my_sivi_ai/widgets/tab_item.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                title: Container(
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
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: tabController,
            children: [
              ListView.builder(
                primary: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(user.initials)),
                    title: Text(user.fullName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              ),

              ListView.builder(
                primary: false,
                physics: const ClampingScrollPhysics(),
                itemCount: 15,
                // itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  // final chat = chatHistory[index];
                  return ListTile(
                    // leading: CircleAvatar(child: Text(chat.initials)),
                    title: Text("Hello"),
                    // subtitle: Text(chat.lastMessage),
                    // trailing: Text(chat.time),
                  );
                },
              ),
            ],
          ),
        ),

        floatingActionButton: index == 0
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {},
              )
            : null,
      ),
    );
  }
}
