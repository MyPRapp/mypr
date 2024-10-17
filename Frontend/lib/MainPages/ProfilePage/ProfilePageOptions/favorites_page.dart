import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:provider/provider.dart';

import '../../../Globals/structs.dart';
import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/club_provider.dart';
import '../../../Widgets/home_page_widgets.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions once to avoid repeated calls
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    List<ClubInfoStruct> likedClubs = context
        .watch<LikedClubsProvider>()
        .getAllLikedClubs(context.read<ClubProvider>().allClubs);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context, screenHeight, screenWidth),
        body: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(255, 68, 3, 3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: likedClubs.isNotEmpty
                ? ListView.builder(
                    itemCount: likedClubs.length,
                    itemBuilder: (context, index) {
                      final club = likedClubs[index];
                      if (index < likedClubs.length) {
                        return BigClubCard(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          club: club,
                        );
                      } else {
                        return Column(
                          children: [
                            BigClubCard(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                              club: club,
                            ),
                            SizedBox(
                              height: screenHeight / 40 * 5,
                            )
                          ],
                        );
                      }
                    },
                  )
                : const Center(
                    child: Padding(
                    padding: EdgeInsets.only(bottom: 25),
                    child: Text(
                      'Δεν υπάρχουν αγαπημένα',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
      BuildContext context, double screenHeight, double screenWidth) {
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'ΑΓΑΠΗΜΕΝΑ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      // actions: [
      //   Padding(
      //     padding: EdgeInsets.only(right: screenWidth * 0.02),
      //     child: GestureDetector(
      //       behavior: HitTestBehavior.translucent,
      //       onTap: () {
      //         context.read<LikedClubsProvider>().deleteAllLiked();
      //       },
      //       child: Container(
      //         height: screenHeight * 0.046,
      //         width: screenWidth / 3.3,
      //         decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(7),
      //             color: const Color.fromARGB(43, 145, 145, 145),
      //             border: Border.all(
      //                 width: 2, color: const Color.fromARGB(209, 0, 0, 0))),
      //         alignment: Alignment.center,
      //         child: Text(
      //           textAlign: TextAlign.center,
      //           'Αφαίρεση όλων',
      //           style: TextStyle(
      //             fontSize: screenWidth * 0.03,
      //             fontWeight: FontWeight.w700,
      //             color: const Color.fromARGB(255, 136, 136, 136),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ]
    );
  }
}
