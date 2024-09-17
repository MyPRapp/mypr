import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/club_provider.dart';
import '../../../Widgets/home_page_widgets.dart';
import '../../../global_components.dart';

@RoutePage()
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain screen dimensions once to avoid repeated calls
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(155, 51, 51, 51),
        body: Selector<ClubProvider, List<ClubInfoStruct>>(
          selector: (context, clubProvider) => clubProvider.likedClubs,
          builder: (context, likedClubs, child) {
            return ListView.builder(
              itemCount: likedClubs.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context, screenHeight, screenWidth);
                }
                final club = likedClubs[index - 1];
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
            );
          },
        ),
      ),
    );
  }

  // Create a separate method for the header to keep the build method clean
  Widget _buildHeader(
      BuildContext context, double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
          top: screenHeight * 0.035, bottom: screenHeight * 0.02),
      child: SizedBox(
        height: screenHeight * 0.06,
        width: screenWidth * 2 / 3,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: screenHeight * 0.026 + screenWidth * 0.02,
                  ),
                ),
                Text(
                  'ΑΓΑΠΗΜΕΝΑ',
                  style: TextStyle(
                    color: const Color(0xFF9C0C04),
                    fontSize: screenHeight * 0.026 + screenWidth * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.01),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  context.read<ClubProvider>().deleteAllLiked();
                },
                child: Container(
                  height: screenHeight * 0.05,
                  width: screenWidth / 3,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF9C0C04),
                      border: Border.all(width: 2, color: Colors.black)),
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    'Αφαίρεση όλων',
                    style: TextStyle(
                      fontSize: screenWidth * 0.032,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
