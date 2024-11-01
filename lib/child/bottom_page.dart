import 'package:flutter/material.dart';
import 'package:women_safety/child/bottom_screens/add_contacts.dart';
import 'package:women_safety/child/bottom_screens/recorded_page.dart';
import 'package:women_safety/child/bottom_screens/surrounded_by_men.dart';
import 'package:women_safety/child/bottom_screens/child_home_page.dart';
import 'package:women_safety/child/bottom_screens/profile_page.dart';
import 'package:women_safety/child/bottom_screens/review_page.dart';


class BottomPage extends StatefulWidget {
  const BottomPage({super.key});

  @override
  State<BottomPage> createState() => _BottomPageState();
}

class _BottomPageState extends State<BottomPage> {
  int currentIndex=0;
  List<Widget> pages=[
    HomeScreen(),
    AddContactsPage(),
    SurroundedByMen(),
    RecordedFilesPage(),
    ProfilePage(),
    ReviewPage(),
    
  ];
  onTapped(int index){
    setState(() {
      currentIndex= index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: onTapped,
        items: [BottomNavigationBarItem(
          label: 'Home',
          icon: Icon(Icons.home)),
          BottomNavigationBarItem(
            label: 'Contacts',
          icon: Icon(Icons.contacts)),
          BottomNavigationBarItem(
              label: 'Near_Men',
          icon: Icon(Icons.man)),
          BottomNavigationBarItem(
              label: 'recording',
          icon: Icon(Icons.record_voice_over)),
          BottomNavigationBarItem(
              label: 'Profile',
          icon: Icon(Icons.person)),
          
          ]),
          
    );
  }
}