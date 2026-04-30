import 'package:flutter/material.dart';
import 'home_page.dart';
import 'create_post_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'messages_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  final List<String> pageTitles = [
    'Returnly Home',
    'Create Post',
    'Chat',
    'Profile',
  ];

  final List<Map<String, String>> posts = [
    {
      'title': 'Lost iPhone',
      'description': 'Black iPhone 13 lost near the student center.',
    },
    {
      'title': 'Found Keys',
      'description': 'Set of car keys found near the library entrance.',
    },
    {
      'title': 'Lost Wallet',
      'description': 'Brown leather wallet lost in the parking lot.',
    },
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
     const HomePage(),
     const CreatePostPage(fromNavigationTab: true),
     const MessagesPage(),
     const ProfilePage(),
    ];
      
      
    

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[selectedIndex]),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}