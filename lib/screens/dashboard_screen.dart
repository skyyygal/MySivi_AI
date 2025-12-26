import 'package:flutter/material.dart';
import 'package:my_sivi_ai/screens/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;
  // int innerIndex = 0;
  List<Widget> widgetList = [
    HomeScreen(),
    Text("Offers", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
    Text(
      'Settings',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    ),
  ];
  final List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  Widget buildTab(int tabIndex, Widget child) {
    return Navigator(
      key: navigatorKeys[tabIndex],
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (_) => child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w700),

        onTap: (value) {
          setState(() {
            index = value;
          });
          print(index);
        },
        currentIndex: index,
        selectedItemColor: Colors.indigoAccent,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(Icons.chat_bubble_outline, size: 20),
            ),

            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(Icons.sell_outlined, size: 20),
            ),
            label: 'Offers',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Icon(Icons.settings_outlined, size: 20),
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
