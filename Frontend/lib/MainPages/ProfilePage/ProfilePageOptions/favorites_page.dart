import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/club_provider.dart';
import '../../../Widgets/home_page_widgets.dart';
import '../../../global_components.dart';

@RoutePage()
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  const Text(
                    'ΑΓΑΠΗΜΕΝΑ',
                    style: TextStyle(
                        color: Color(0xFF9C0C04),
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 5),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                  color: Colors.black, width: 2),
                            ),
                            backgroundColor: const Color(0xFF9C0C04),
                          ),
                          onPressed:
                              context.read<ClubProvider>().deleteAllLiked,
                          child: const Text(
                            'Αφαίρεση όλων',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
            Selector<ClubProvider, List<ClubInfoStruct>>(
              selector: (context, clubProvider) => clubProvider.likedClubs,
              builder: (context, likedClubs, child) {
                return SizedBox(
                  height: likedClubs.length * screenHeight / 5,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: likedClubs.length,
                    itemBuilder: (context, index) {
                      final club = likedClubs[index];
                      final double screenHeight =
                          MediaQuery.sizeOf(context).height;
                      final double screenWidth =
                          MediaQuery.sizeOf(context).width;
                      return BigClubCard(
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        club: club,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
