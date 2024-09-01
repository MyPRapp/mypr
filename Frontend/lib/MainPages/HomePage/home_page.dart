import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/global_.components.dart';
import 'package:provider/provider.dart';

import '../../Providers/club_provider.dart';

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
      context.read<BottomNavBarVisibility>().show();
    });
  }

  Future<void> _refresh() async {
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.fetchClubsAndCatalogues();
    print('Page refreshed');
  }

  void navigateToSearchTab(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    // Set the active tab index to 1 (SearchNavigation)
    if (tabsRouter.activeIndex != 1) {
      tabsRouter.setActiveIndex(1);
    }

    // Ensure SearchRoute is pushed on the SearchNavigation stack
    // AutoRouter.of(context).push(const SearchNavigation());
  }

  @override
  Widget build(BuildContext context) {
    ClubProvider clubProvider = context.watch<ClubProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                Container(
                  height: constraints.maxHeight,
                  color: const Color.fromARGB(197, 40, 40, 40),
                  // decoration: const BoxDecoration(
                  //   image: DecorationImage(
                  //     image:
                  //         AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                ),
                RefreshIndicator(
                  onRefresh: _refresh,
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
                      //   padding:
                      //       const EdgeInsets.only(left: 20, top: 15, bottom: 10),
                      //   child: Text(
                      //     'Επιλογές κοντά σου',
                      //     style: textStyle1(),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 200,
                      //   child: ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     itemCount: clubProvider.allClubs.length,
                      //     itemBuilder: (context, index) {
                      //       final club = clubProvider.allClubs[index];
                      //       return SmallClubCard(
                      //         club: club,
                      //       );
                      //     },
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 10, bottom: 10),
                        child: Text(
                          'Όλα τα αποτελέσματα',
                          style: textStyle1(),
                        ),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: clubProvider.allClubs.length,
                        itemBuilder: (context, index) {
                          final club = clubProvider.allClubs[index];
                          return BigClubCard(
                            club: club,
                          );
                        },
                      ),
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

  TextStyle textStyle1() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  TextStyle textStyle2() {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color(0xFF9C0C04),
    );
  }
}
