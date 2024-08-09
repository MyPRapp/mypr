import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/MainPages/SearchPage/search_page.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
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
    ClubProvider clubProvider = context.read<ClubProvider>();
    await clubProvider.fetchClubsAndCatalogues();
  }

  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    ClubProvider clubProvider = context.watch<ClubProvider>();

    tabsRouter.addListener(() {
      if (tabsRouter.activeIndex == 1) {
        FocusManager.instance.primaryFocus?.unfocus();
        SearchPageState.requestFocus();
      }
    });
    AutoRouter.of(context).isRoot;
    AutoRouter.of(context).isTopMost;
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
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
                    club: club,
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
                  return BigClubCard(
                    club: club,
                  );
                },
              ),
            ),
          ]),
        )
      ]),
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
