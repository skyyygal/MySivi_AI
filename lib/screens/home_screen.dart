import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sivi_ai/controllers/chat_history_provider.dart';
import 'package:my_sivi_ai/controllers/user_provider.dart';
import 'package:my_sivi_ai/core/constants.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/widgets/chat_history.dart';
import 'package:my_sivi_ai/widgets/user.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final bucket = PageStorageBucket();
  int index = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      ref.read(usersProvider.notifier).fetchUsers();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    // _scrollController.dispose();
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
                  ref.read(usersProvider.notifier).addUser(newUser);

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
    final users = ref.watch(usersProvider);
    final chatHistory = ref.watch(chatHistoryProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        floatingActionButton: index == 0
            ? FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: Colors.indigoAccent,
                onPressed: addNewUser,
                child: const Icon(Icons.add, color: whiteColor),
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
                backgroundColor: whiteColor,
                surfaceTintColor: whiteColor,
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

                        labelColor: blackColor,
                        unselectedLabelColor: Colors.black45,
                        padding: EdgeInsets.all(2),
                        indicator: BoxDecoration(
                          color: whiteColor,
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
          body: PageStorage(
            bucket: bucket,
            child: TabBarView(
              controller: _tabController,
              children: [UserListWidget(), ChatHistoryWidget()],
            ),
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

        labelColor: blackColor,
        unselectedLabelColor: blackColor,
        padding: EdgeInsets.all(2),
        indicator: BoxDecoration(
          color: whiteColor,
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
