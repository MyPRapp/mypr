import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/Widgets/search_widget.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int i = 0;
  bool isLoading = false;
  late List<bool> daysOpen;
  List<dynamic> clubListFromDb = [];
  String errorMessage = 'Failed to load club info(HomePage)';

  @override
  Widget build(BuildContext context) {
    if (i == 0) {
      _fetchClubs();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(children: [
        Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                    fit: BoxFit.fill))),
        ListView(children: [
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
                itemCount: clubListFromDb.length,
                itemBuilder: (context, index) {
                  daysOpen = _daysOpen(index);

                  return SmallClubCard(
                    clubName: clubListFromDb[index]['club_name'],
                    minPrice: 110,
                    maxPersons: 5,
                    liked: false,
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
            height: 500,
            child: ListView.builder(
                itemCount: clubListFromDb.length,
                itemBuilder: (context, index) {
                  daysOpen = _daysOpen(index);

                  return BigClubCard(
                    clubName: clubListFromDb[index]['club_name'],
                    stars: double.parse(clubListFromDb[index]['rating']),
                    address: clubListFromDb[index]['location'],
                    minPrice: 110,
                    maxPersons: 5,
                    monday: daysOpen[0],
                    tuesday: daysOpen[1],
                    wednesday: daysOpen[2],
                    thursday: daysOpen[3],
                    friday: daysOpen[4],
                    saturday: daysOpen[5],
                    sunday: daysOpen[6],
                    liked: false,
                  );
                }),
          ),
        ]),
      ]),
    );
  }

  //Methods and classes used by HomePage
  TextStyle textStyle1() {
    return const TextStyle(
        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
  }

  TextStyle textStyle2() {
    return const TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C0C04));
  }

  List<bool> _daysOpen(int index) {
    final String availabilityInBytes = clubListFromDb[index]['availability'];

    List<bool> daysOpen =
        availabilityInBytes.split('').map((char) => char == '1').toList();
    return daysOpen;
  }

  Future<void> _fetchClubs() async {
    const url =
        'http://127.0.0.1:8000/api/clubs/print/'; // Replace with your API URL

    setState(() {
      isLoading = true;
      errorMessage = '';
      i++;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(jsonDecode(response.body));
        setState(() {
          clubListFromDb = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load clubs');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
}
