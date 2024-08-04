// HomePage.dart
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  bool isLoading = true;
  late List<bool> daysOpen;
  dynamic clubList, catalogueList;
  List<dynamic> clubListFromDB = [];
  Map<int, List<dynamic>> catalogueListFromDB = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
    });

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(children: [
        Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                    fit: BoxFit.fill))),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Consumer<ClubProvider>(
            builder: (context, clubProvider, child) {
              return ListView(children: [
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
                          liked: clubProvider.isLiked(club.clubName),
                        );
                      }),
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
                        daysOpen = _daysOpen(club.clubAvailability);
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
                            liked: clubProvider.isLiked(club.clubName));
                      }),
                ),
              ]);
            },
          ),
      ]),
    );
  }

  Future<void> _fetchData() async {
    await _fetchClubs();
    for (int i = 0; i < clubListFromDB.length; i++) {
      if (clubListFromDB[i].isEmpty) {
        print("ERROR: clubListFromDB[$i] is Empty!");
        break;
      }
      clubList = clubListFromDB[i];
      int id = clubList['id'];
      await _fetchCatalogues(id);
      catalogueList = catalogueListFromDB[id]?[0];
      if (catalogueList != null) {
        final club = ClubInfoStruct(
          clubID: id,
          clubName: clubList['club_name'],
          clubMinPrice: (double.parse(catalogueList['price'])).toInt(),
          clubMaxPersons: catalogueList['max_person'],
          clubLocation: clubList['location'],
          clubRating: double.parse(clubList['rating']),
          clubAvailability: clubList['availability'],
        );
        if (mounted) {
          context.read<ClubProvider>().addOrUpdateClub(club);
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchClubs() async {
    const url =
        'http://127.0.0.1:8000/api/clubs/print/'; // Replace with your API URL

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          clubListFromDB = data;
        });
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCatalogues(int id) async {
    var url =
        'http://127.0.0.1:8000/api/clubs/$id/catalogue'; // Replace with your API URL

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          catalogueListFromDB[id] = data;
        });
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching catalogues: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<bool> _daysOpen(String availabilityInBytes) {
    List<bool> daysOpen =
        availabilityInBytes.split('').map((char) => char == '1').toList();
    return daysOpen;
  }

  TextStyle textStyle1() {
    return const TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
  }

  TextStyle textStyle2() {
    return const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C0C04));
  }
}
