// ignore_for_file: unused_import
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 22,
      currentIndex: 0,
      showUnselectedLabels: true,
      unselectedLabelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      selectedLabelStyle:
          const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      fixedColor: Colors.black,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: Colors.black,
          ),
          label: 'Αρχική',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black), label: 'Αναζήτηση'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black), label: 'Προφίλ')
      ],
      backgroundColor: const Color(0xFF9c0c04),
    );
  }
}
