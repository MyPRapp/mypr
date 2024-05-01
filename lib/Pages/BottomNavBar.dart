import 'package:flutter/material.dart';
import 'package:mypr/Pages/HomePage.dart';
import 'package:mypr/Pages/ProfilePage.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  Widget _currentWidget = Container();
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  void _loadScreen() {
    switch (_currentIndex) {
      case 0:
        return setState(() => _currentWidget = const HomePage());
      case 2:
        return setState(() => _currentWidget = const ProfilePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentWidget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _loadScreen();
        },
        iconSize: 22,
        showUnselectedLabels: true,
        fixedColor: Colors.black,
        backgroundColor: const Color(0xFF9c0c04),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        selectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Αρχική',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            label: 'Αναζήτηση',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Προφίλ',
          ),
        ],
      ),
    );
  }
}

/*class BottomNavBar extends StatelessWidget {
  BottomNavBar({super.key});

  final screens = [
    HomePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[0],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) => ProfilePage(),
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
              icon: Icon(Icons.search, color: Colors.black),
              label: 'Αναζήτηση'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.black), label: 'Προφίλ')
        ],
        backgroundColor: const Color(0xFF9c0c04),
      ),
    );
  }
}
*/
