import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/Widgets/search_widget.dart';
import 'package:provider/provider.dart';

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
    // This function will be called when the user pulls down to refresh
    // You can add your refresh logic here
  }

  @override
  Widget build(BuildContext context) {
    ClubProvider clubProvider = context.watch<ClubProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10, bottom: 10),
                  child: Text(
                    'Καλησπέρα!',
                    style: textStyle1(),
                  ),
                ),
                const SearchWidget(),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 30),
                  child: Text(
                    'Επιλογές κοντά σου',
                    style: textStyle1(),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: clubProvider.allClubs.length,
                    itemBuilder: (context, index) {
                      final club = clubProvider.allClubs[index];
                      return SmallClubCard(
                        clubName: club.clubName,
                        minPrice: club.clubMinPrice,
                        maxPersons: club.clubMaxPersons,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Text(
                    'Όλα τα αποτελέσματα',
                    style: textStyle1(),
                  ),
                ),
                SizedBox(
                  height: clubProvider.allClubs.length * 180,
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clubProvider.allClubs.length,
                    itemBuilder: (context, index) {
                      final club = clubProvider.allClubs[index];
                      final daysOpen = _daysOpen(club.clubAvailability);
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
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<bool> _daysOpen(String availabilityInBytes) {
    return availabilityInBytes.split('').map((char) => char == '1').toList();
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
