import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:provider/provider.dart';

import '../../../Globals/global_components.dart';
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
        appBar: buildAppBar(context, 'ΑΓΑΠΗΜΕΝΑ'),
        body: Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
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
                : Center(
                    child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Text(
                      'Δεν υπάρχουν αγαπημένα',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                  )),
          ),
        ),
      ),
    );
  }
}
