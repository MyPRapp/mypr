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
              padding: const EdgeInsets.only(top: 20),
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
                  )
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
                      final daysOpen = _daysOpen(clubProvider, club.clubName);
                      return BigClubCard(
                        clubName: club.clubName,
                        stars: club.clubRating,
                        address: club.clubLocation,
                        minPrice: club.clubMinPrice,
                        maxPersons: club.clubMaxPersons,
                        monday: daysOpen[0],
                        tuesday: daysOpen[1],
                        wednesday: daysOpen[2],
                        thursday: daysOpen[3],
                        friday: daysOpen[4],
                        saturday: daysOpen[5],
                        sunday: daysOpen[6],
                        liked: clubProvider.isLiked(club.clubName),
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

  List<bool> _daysOpen(ClubProvider clubProvider, String clubName) {
    final String availabilityInBytes =
        clubProvider.getClubAvailability(clubName);

    List<bool> daysOpen =
        availabilityInBytes.split('').map((char) => char == '1').toList();
    return daysOpen;
  }
}
