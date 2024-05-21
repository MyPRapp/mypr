import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/Widgets/search_widget.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
        ListView(children: [
          const Padding(
            padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
            child: Text(
              'Καλησπέρα!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const SearchWidget(),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 30),
            child: Text(
              'Επιλογές κοντά σου',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: clubNamesList.length,
              itemBuilder: (_, index) =>
                  HomePageSmallCard(clubName: clubNamesList[index]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
            child: Text(
              'Όλα τα αποτελέσματα',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const HomePageBigCard(
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
          const HomePageBigCard(
            clubName: 'Akanthus',
            address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
            stars: 3.5,
            minPrice: 120,
            maxPersons: 5,
            monday: true,
            tuesday: false,
            wednesday: false,
            thursday: false,
            friday: true,
            saturday: true,
            sunday: true,
          ),
          const HomePageBigCard(
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
          const HomePageBigCard(
            clubName: 'Boutique',
            address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
            stars: 3.5,
            minPrice: 120,
            maxPersons: 6,
            monday: false,
            tuesday: false,
            wednesday: false,
            thursday: false,
            friday: true,
            saturday: true,
            sunday: true,
          ),
          const HomePageBigCard(
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
        ]),
      ]),
    );
  }
}

List clubNamesList = [
  'Lohan',
  'Blast',
  'Toyroom',
  'Akanthus',
  'Syko',
  'Boutique'
];
