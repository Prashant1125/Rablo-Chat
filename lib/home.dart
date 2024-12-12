import 'package:flutter/material.dart';

import 'screens/chat.dart';
import 'screens/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int myIndex = 0;

  List<Widget> widgetlist = const [
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green.withOpacity(0.9),
        currentIndex: myIndex,
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.group), label: "Chat", tooltip: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "My Profile",
              tooltip: 'My Profile'),
        ],
      ),
      body: Container(
        child: widgetlist[myIndex],
      ),
    );
  }
}
