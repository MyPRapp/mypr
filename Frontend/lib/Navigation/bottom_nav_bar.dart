import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../global_components.dart';

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
        HomeNavigation(),
        SearchNavigation(),
        ProfileNavigation(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final bottomNavBarVisibility = context.watch<BottomNavBarVisibility>();
        final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

        void onTap(int index) {
          if (tabsRouter.activeIndex == index) {
            // Reset the stack to the initial route of the selected tab
            tabsRouter.stackRouterOfIndex(index)?.popUntilRoot();
          } else {
            // Set the active index to switch tabs
            tabsRouter.setActiveIndex(index);
          }
        }

        final double screenHeight = MediaQuery.sizeOf(context).height;
        final double screenWidth = MediaQuery.sizeOf(context).width;
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              child,
              if (bottomNavBarVisibility.isVisible && !isKeyboardVisible)
                Positioned(
                  left: screenWidth / 10,
                  right: screenWidth / 10,
                  bottom: screenHeight / 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: screenHeight / 40 * 3.5,
                      width: screenWidth - screenWidth / 5,
                      child: BottomNavigationBar(
                        currentIndex: tabsRouter.activeIndex,
                        onTap: onTap,
                        showUnselectedLabels: true,
                        selectedItemColor: const Color(0xFF9C0C04),
                        unselectedItemColor: Colors.white,
                        backgroundColor: Colors.black,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                        selectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
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
            ],
          ),
        );
      },
    );
  }
}
