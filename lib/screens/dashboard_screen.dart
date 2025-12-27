import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_sivi_ai/controllers/user_provider.dart';
import 'package:my_sivi_ai/core/constants.dart';
import 'package:my_sivi_ai/screens/home_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabProvider);
    final navigatorKeys = [
      GlobalKey<NavigatorState>(),
      GlobalKey<NavigatorState>(),
      GlobalKey<NavigatorState>(),
    ];

    Widget buildTab(int tabIndex, Widget child) {
      return Navigator(
        key: navigatorKeys[tabIndex],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
      );
    }

    return Scaffold(
      backgroundColor: whiteColor,
      body: IndexedStack(
        index: index,
        children: [
          buildTab(0, const HomeScreen()),
          buildTab(1, const Center(child: Text("Offers"))),
          buildTab(2, const Center(child: Text("Settings"))),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        currentIndex: index,
        selectedItemColor: Colors.indigoAccent,
        onTap: (value) {
          ref.read(selectedTabProvider.notifier).state = value;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell_outlined, size: 20),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 20),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
