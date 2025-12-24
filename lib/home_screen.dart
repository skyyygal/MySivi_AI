import 'package:flutter/material.dart';
import 'package:my_sivi_ai/tab_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // appBar: AppBar(
        //   bottom: PreferredSize(
        //     preferredSize: Size.fromHeight(40),
        //     child: ClipRRect(
        //       borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
        //       child: Container(
        //         height: 40,
        //         margin: EdgeInsets.symmetric(horizontal: 20),
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.all(Radius.circular(10)),
        //           color: Colors.grey.shade300,
        //         ),
        //         child: TabBar(
        //           indicatorSize: TabBarIndicatorSize.tab,
        //           dividerColor: Colors.transparent,
        //           indicator: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.all(Radius.circular(10)),
        //           ),
        //           labelColor: Colors.black,
        //           unselectedLabelColor: Colors.black45,

        //           tabs: [
        //             TabItem(title: "User List"),
        //             TabItem(title: "Chat History"),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        body: Column(
          children: [
            Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.grey.shade300,
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black45,

                tabs: [
                  TabItem(title: "User List"),
                  TabItem(title: "Chat History"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                children: [
                  Center(child: Text('User List')),
                  Center(child: Text('Char History')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
