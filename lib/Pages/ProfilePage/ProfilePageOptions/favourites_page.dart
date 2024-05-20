import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';

@RoutePage()
class FavouritesPage extends StatelessWidget {
  const FavouritesPage({super.key});

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
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const BigClubCard(
            clubName: 'Lohan',
            address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
            stars: 4.5,
            minPrice: 120,
            maxPersons: 5,
            monday: false,
            tuesday: false,
            wednesday: false,
            thursday: false,
            friday: true,
            saturday: true,
            sunday: true,
          ),
          const BigClubCard(
            clubName: 'Toyroom',
            address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
            stars: 4,
            minPrice: 110,
            maxPersons: 5,
            monday: true,
            tuesday: true,
            wednesday: false,
            thursday: false,
            friday: true,
            saturday: true,
            sunday: true,
          ),
          const BigClubCard(
            clubName: 'Syko',
            stars: 5,
            address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
            minPrice: 110,
            maxPersons: 5,
            monday: false,
            tuesday: false,
            wednesday: true,
            thursday: false,
            friday: true,
            saturday: true,
            sunday: true,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to first route when tapped.
                Navigator.pop(context);
              },
              child: const Text('Go back!'),
            ),
          ),
        ],
      ),
    );
  }
}
