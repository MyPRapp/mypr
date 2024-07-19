import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.gr.dart';

@RoutePage()
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  double bottomBarHeight = 60;
  bool _show = true;

  void showBottomBar() {
    bottomBarHeight = 60;
    setState(() {
      _show = true;
    });
  }

  void hideBottomBar() {
    bottomBarHeight = 0;
    setState(() {
      _show = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ModalRoute.of(context)?.settings.name;
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        SearchRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return Scaffold(
            backgroundColor: Colors.black,
            body: child,
            bottomNavigationBar: SizedBox(
                height: bottomBarHeight,
                child: _show
                    ? BottomNavigationBar(
                        currentIndex: tabsRouter.activeIndex,
                        onTap: (value) {
                          tabsRouter.setActiveIndex(value);
                        },
                        iconSize: 22,
                        showUnselectedLabels: true,
                        fixedColor: Colors.black,
                        backgroundColor: const Color(0xFF9c0c04),
                        unselectedLabelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        selectedLabelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
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
                      )
                    : Container(height: 0)));
      },
    );
  }
}





/*class BottomNavBar extends StatefulWidget {
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
          switch (index) {
            case 0:
              return setState(() => _currentWidget = const HomePage());
            case 2:
              return setState(() => _currentWidget = const ProfilePage());
          }
          //setState(() => _currentIndex = index);
          //_loadScreen();
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
}*/

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
