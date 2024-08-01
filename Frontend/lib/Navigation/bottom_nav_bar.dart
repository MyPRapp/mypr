import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class BottomNavBarPage extends StatefulWidget {
  const BottomNavBarPage({super.key});

  @override
  State<BottomNavBarPage> createState() => _BottomNavBarPageState();
}

class _BottomNavBarPageState extends State<BottomNavBarPage> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        SearchRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final bottomNavBarVisibility = context.watch<BottomNavBarVisibility>();

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
              if (bottomNavBarVisibility.isVisible)
                Positioned(
                  left: 40,
                  right: 40,
                  bottom: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        height: 70,
                        child: BottomNavigationBar(
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
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
