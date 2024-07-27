import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/nav_bar_visibility.dart';
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

  void updateVisibility(bool isVisible) {
    setState(() {
      _show = isVisible;
      bottomBarHeight = isVisible ? 60 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NavBarVisibility(
      isVisible: _show,
      updateVisibility: updateVisibility,
      child: AutoTabsRouter(
        routes: const [
          HomeRoute(),
          SearchRoute(),
          ProfileRoute(),
        ],
        builder: (context, child) {
          final tabsRouter = AutoTabsRouter.of(context);

          void onTap(int index) {
            if (tabsRouter.activeIndex == index) {
              // Reset the stack to the initial route of the selected tab
              tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
            } else {
              // Set the active index to switch tabs
              tabsRouter.setActiveIndex(index);
            }
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                child,
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: bottomBarHeight,
                      child: _show
                          ? BottomNavigationBar(
                              currentIndex: tabsRouter.activeIndex,
                              onTap: onTap,
                              iconSize: 22,
                              showUnselectedLabels: true,
                              selectedItemColor: const Color(0xFF9C0C04),
                              unselectedItemColor: Colors.white,
                              backgroundColor: Colors.black,
                              unselectedLabelStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              selectedLabelStyle: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                              items: const [
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.home),
                                  label: 'Αρχική',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.search),
                                  label: 'Αναζήτηση',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.person),
                                  label: 'Προφίλ',
                                ),
                              ],
                            )
                          : Container(height: 0),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
