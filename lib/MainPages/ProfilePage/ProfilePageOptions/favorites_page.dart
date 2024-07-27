import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';

@RoutePage()
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  FavoritesPageState createState() => FavoritesPageState();
}

class FavoritesPageState extends State<FavoritesPage> {
  final List<Map<String, dynamic>> favoriteClubs = [
    {
      'id': 1, // Add unique id
      'clubName': 'Lohan',
      'address': 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
      'stars': 4.5,
      'minPrice': 120,
      'maxPersons': 5,
      'monday': false,
      'tuesday': false,
      'wednesday': false,
      'thursday': false,
      'friday': true,
      'saturday': true,
      'sunday': true,
      'liked': true,
    },
    {
      'id': 2, // Add unique id
      'clubName': 'Toyroom',
      'address': 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
      'stars': 4.0,
      'minPrice': 110,
      'maxPersons': 5,
      'monday': true,
      'tuesday': true,
      'wednesday': false,
      'thursday': false,
      'friday': true,
      'saturday': true,
      'sunday': true,
      'liked': true,
    },
    {
      'id': 3, // Add unique id
      'clubName': 'Syko',
      'address': 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
      'stars': 5.0,
      'minPrice': 110,
      'maxPersons': 5,
      'monday': false,
      'tuesday': false,
      'wednesday': true,
      'thursday': false,
      'friday': true,
      'saturday': true,
      'sunday': true,
      'liked': true,
    },
  ];

  void removeCard(int id) {
    setState(() {
      favoriteClubs.removeWhere((club) => club['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF9c0c04),
        title: const Text(
          'ΑΓΑΠΗΜΕΝΑ',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: favoriteClubs.length,
        itemBuilder: (context, index) {
          final club = favoriteClubs[index];
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: HomePageBigCard(
              key: ValueKey(club['id']), // Use unique key
              clubName: club['clubName'],
              address: club['address'],
              stars: club['stars'],
              minPrice: club['minPrice'],
              maxPersons: club['maxPersons'],
              monday: club['monday'],
              tuesday: club['tuesday'],
              wednesday: club['wednesday'],
              thursday: club['thursday'],
              friday: club['friday'],
              saturday: club['saturday'],
              sunday: club['sunday'],
              liked: club['liked'],
              onRemove: () => removeCard(club['id']),
            ),
          );
        },
      ),
    );
  }
}
