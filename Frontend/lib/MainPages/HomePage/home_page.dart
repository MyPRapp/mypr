import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/MainPages/SearchPage/search_page.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    await clubProvider.loadClubsFromPreferences();
    await clubProvider.fetchClubsAndCatalogues();
    await clubProvider.loadLikedClubs();

    // This function will be called when the user pulls down to refresh
    // You can add your refresh logic here
  }

  Future<void> _clearSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    ClubProvider clubProvider = context.watch<ClubProvider>();

    // Add a listener to monitor active index changes
    tabsRouter.addListener(() {
      if (tabsRouter.activeIndex == 1) {
        // Trigger some mechanism to focus the search bar in SearchPage
        FocusManager.instance.primaryFocus
            ?.unfocus(); // Ensure any other focus is removed
        SearchPageState.requestFocus();
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(children: [
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
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, bottom: 10),
              child: Text(
                'Καλησπέρα!',
                style: textStyle1(),
              ),
            ),
            GestureDetector(
              onTap: () {
                tabsRouter.setActiveIndex(1);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, left: 10, right: 10, bottom: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border:
                        Border.all(width: 0.4, color: const Color(0xFF9C0C04)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: const TextField(
                    enabled: false,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for clubs',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: _refresh, child: const Text('REFRESH PAGE')),
            ElevatedButton(
                onPressed: _clearSharedPreferences,
                child: const Text('CLEAR SP')),
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
              height: clubProvider.allClubs.length * 190,
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
          ]),
        )
      ]),
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
