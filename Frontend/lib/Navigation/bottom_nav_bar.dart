import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        HomeNavigation(),
        SearchNavigation(),
        ProfileNavigation(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final bottomNavBarVisibility = context.watch<BottomNavBarVisibility>();
        final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

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
              if (bottomNavBarVisibility.isVisible && !isKeyboardVisible)
                Positioned(
                  left: 40.w,
                  right: 40.w,
                  bottom: 40.h,
                  child: SafeArea(
                    bottom: true, // Only apply SafeArea on the bottom
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: const Color.fromARGB(255, 18, 18, 18),
                      ),
                      child: BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        currentIndex: tabsRouter.activeIndex,
                        onTap: onTap,
                        showUnselectedLabels: true,
                        selectedItemColor: const Color(0xFF9C0C04),
                        unselectedItemColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Colors.transparent,
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15.sp,
                        ),
                        selectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                        items: [
                          BottomNavigationBarItem(
                            icon: Icon(Icons.home, size: 18.sp),

                            label:
                                'Αρχική', // This label will use the responsive font size
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.search, size: 18.sp),

                            label: 'Αναζήτηση', // Responsive label
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(Icons.person, size: 18.sp),

                            label: 'Προφίλ', // Responsive label
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

class BottomNavBarVisibility extends ChangeNotifier {
  bool _isVisible = false;

  bool get isVisible => _isVisible;

  void show() {
    _isVisible = true;

    notifyListeners();
  }

  void hide() {
    _isVisible = false;

    notifyListeners();
  }
}
