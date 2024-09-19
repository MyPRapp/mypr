import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:provider/provider.dart';

import '../../Navigation/bottom_nav_bar.dart';
import '../../Providers/club_provider.dart';
import '../../Providers/user_provider.dart';
import '../../routes/app_router.gr.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<GlobalStateProvider>().isAuthenticated ||
          context.read<UserProvider>().userDetails.userID < 0) {
        context.read<BottomNavBarVisibility>().hide();
        context.read<GlobalStateProvider>().isAuthenticated = false;
        context.router.replaceAll([const LoginRoute()]);
      } else {
        context.read<BottomNavBarVisibility>().show();
      }
      if (context.read<ClubProvider>().allClubs.isEmpty) {
        _syncClubs();
      }
    });
  }

  Future<void> _syncClubs() async {
    print('\x1B[33m------------SYNCING CLUBS------------');
    await context.read<ClubProvider>().syncClubs();
    print('\x1B[32m------------SYNCED CLUBS------------');
  }

  void navigateToSearchTab(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    // Set the active tab index to 1 (SearchNavigation)
    if (tabsRouter.activeIndex != 1) {
      tabsRouter.setActiveIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(197, 40, 40, 40),
          body: SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: RefreshIndicator(
              onRefresh: _syncClubs,
              child: ListView(
                children: [
                  SizedBox(
                    height: screenHeight / 13,
                    width: screenWidth,
                    child: Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.02),
                            child: Image.asset(
                              'assets/otherPhotos/Logo_v2.2-removebg(cropped).png', // Replace with your logo asset path
                              height: screenHeight / 13,
                              width: screenWidth / 4,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: screenWidth * 0.02),
                            alignment: Alignment.center,
                            height: screenHeight / 13,
                            width: screenWidth / 2.2,
                            child: GestureDetector(
                              onTap: () {
                                navigateToSearchTab(context);
                              },
                              child: const TextField(
                                enabled: false,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Αναζήτηση',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 0, 0, 0),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon:
                                      Icon(Icons.search, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /*  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.02, top: screenHeight * 0.008),
                    child: Text('Επιλογές κοντά σου',
                        style: TextStyle(
                          fontSize: screenWidth * 0.02 + screenHeight * 0.0094,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ), //TODO smallClubCard
                  Consumer<ClubProvider>(builder: (context, clubProvider, _) {
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: clubProvider.allClubs.length,
                        itemBuilder: (context, index) {
                          final club = clubProvider.allClubs[index];
                          return SmallClubCard(
                            club: club,
                          );
                        },
                      ),
                    );
                  }), */
                  Padding(
                    padding: EdgeInsets.only(
                        left: screenWidth * 0.03,
                        top: screenHeight * 0.035,
                        bottom: screenHeight * 0.02),
                    child: Text(
                      'Όλα τα αποτελέσματα',
                      style: TextStyle(
                        fontSize: screenWidth * 0.02 + screenHeight * 0.0125,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Consumer<ClubProvider>(
                    builder: (context, clubProvider, _) {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: clubProvider.allClubs.length,
                        itemBuilder: (context, index) {
                          final club = clubProvider.allClubs[index];

                          return BigClubCard(
                            club: club,
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                          );
                        },
                      );
                    },
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    'Περισσότερα club έρχονται σύντομα...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenHeight / 40 * 6)
                ],
              ),
            ),
          )),
    );
  }
}
