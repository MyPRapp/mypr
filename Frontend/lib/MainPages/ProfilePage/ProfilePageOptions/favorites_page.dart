import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:provider/provider.dart';

@RoutePage()
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    ClubProvider clubProvider = context.watch<ClubProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });

    void onBackPressed(BuildContext context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BottomNavBarVisibility>().show();
      });
    }

    return PopScope(
      onPopInvoked: (bool isPopInvoked) {
        onBackPressed(context);
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
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<BottomNavBarVisibility>().show();
                        });
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
                          onPressed: clubProvider.deleteAllLiked,
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
            Consumer<ClubProvider>(
              builder: (context, clubProvider, child) {
                final likedClubs = clubProvider.likedClubs;
                return SizedBox(
                  height: likedClubs.length * 200,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: likedClubs.length,
                    itemBuilder: (context, index) {
                      final club = likedClubs[index];
                      return BigClubCard(
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
