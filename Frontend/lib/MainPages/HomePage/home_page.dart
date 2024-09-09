import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/global_components.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../../Providers/club_provider.dart';
import '../../Providers/user_provider.dart';

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
          context.read<UserProvider>().userDetails!.userID < 0) {
        context.read<BottomNavBarVisibility>().hide();
        context.router.replaceAll([const LoginRoute()]);
      } else {
        context.read<BottomNavBarVisibility>().show();
      }
    });
  }

  Future<void> _syncClubs() async {
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.syncClubs();
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
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                Container(
                  height: constraints.maxHeight,
                  color: const Color.fromARGB(197, 40, 40, 40),
                ),
                RefreshIndicator(
                  onRefresh: _syncClubs,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 20, left: 10, right: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 170,
                              alignment: Alignment.topLeft,
                              child: Image.asset(
                                'assets/otherPhotos/Logo_v2.2-removebg(cropped).png', // Replace with your logo asset path
                                height: 40,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                navigateToSearchTab(context);
                              },
                              child: Container(
                                height: 70,
                                width:
                                    200, // Set a width to align the search bar properly
                                alignment: Alignment.center,
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
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
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 20, top: 15, bottom: 10),
                      //   child: Text(
                      //     'Επιλογές κοντά σου',
                      //     style: textStyle1(),
                      //   ),
                      // ),
                      // Consumer<ClubProvider>(
                      //     builder: (context, clubProvider, _) {
                      //   return SizedBox(
                      //     height: 200,
                      //     child: ListView.builder(
                      //       scrollDirection: Axis.horizontal,
                      //       itemCount: clubProvider.allClubs.length,
                      //       itemBuilder: (context, index) {
                      //         final club = clubProvider.allClubs[index];
                      //         return SmallClubCard(
                      //           club: club,
                      //         );
                      //       },
                      //     ),
                      //   );
                      // }),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 10, bottom: 10),
                        child: Text(
                          'Όλα τα αποτελέσματα',
                          style: textStyle1(),
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
                              );
                            },
                          );
                        },
                      ),
                      Container(
                          alignment: Alignment.topCenter,
                          height: 50,
                          child: const Text(
                            'Περισσότερα club έρχονται σύντομα...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                      const SizedBox(height: 100)
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
