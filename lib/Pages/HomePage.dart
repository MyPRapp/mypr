import 'package:flutter/material.dart';
import 'package:mypr/Pages/ReservationPage.dart';
import 'package:mypr/Widgets/HomePageWidgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                fit: BoxFit.fill)),
      ),
      ListView(children: [
        const Padding(
          padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
          child: Text(
            'Καλησπέρα!',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SearchWidget(),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 30),
          child: Text(
            'Επιλογές κοντά σου',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: clubNamesList.length,
            itemBuilder: (_, index) =>
                ClubsNearYouCard(clubName: clubNamesList[index]),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Text(
            'Όλα τα αποτελέσματα',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        BigClubCard(
          clubName: 'Syko',
          stars: 4.5,
          address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
          minPrice: 110,
          maxPersons: 5,
        ),
        BigClubCard(
          clubName: 'Akanthus',
          address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
          stars: 3.5,
          minPrice: 120,
          maxPersons: 5,
        ),
        BigClubCard(
          clubName: 'Toyroom',
          address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
          stars: 4,
          minPrice: 110,
          maxPersons: 5,
        ),
        BigClubCard(
          clubName: 'Boutique',
          address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
          stars: 4,
          minPrice: 120,
          maxPersons: 6,
        ),
        BigClubCard(
          clubName: 'Lohan',
          address: 'ΙΑΚΧΟΥ 8, ΚΕΡΑΜΕΙΚΟΣ',
          stars: 4.5,
          minPrice: 120,
          maxPersons: 5,
        ),
      ]),
    ]);
  }
}

class BigClubCard extends StatelessWidget {
  BigClubCard({
    super.key,
    required this.clubName,
    required this.address,
    required this.stars,
    required this.minPrice,
    required this.maxPersons,
  });

  final String clubName;
  final String address;
  final double stars;
  final int minPrice;
  final int maxPersons;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReservationPage(
                      clubName: clubName,
                    )),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Card(
            color: Colors.transparent,
            margin: const EdgeInsets.only(left: 10),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  height: 140,
                  width: 130,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                    ),
                  ),
                ),
                BigClubCardInfo(
                    clubName: clubName,
                    address: address,
                    stars: stars,
                    minPrice: minPrice,
                    maxPersons: maxPersons)
              ],
            ),
          ),
        ));
  }
}

class BigClubCardInfo extends StatelessWidget {
  BigClubCardInfo({
    super.key,
    required this.clubName,
    required this.address,
    required this.stars,
    required this.minPrice,
    required this.maxPersons,
  });

  final String clubName;
  final String address;
  final double stars;
  final int minPrice;
  final int maxPersons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NameAndStars(clubName: clubName),
              Text(
                '  $address',
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MinPriceAndMaxPersons(
                    minPrice: minPrice, maxPersons: maxPersons),
                DaysOpen()
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ClubsNearYouCard extends StatelessWidget {
  const ClubsNearYouCard({super.key, required this.clubName});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReservationPage(
                      clubName: clubName,
                    )),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: Card(
            margin: const EdgeInsets.only(bottom: 30),
            color: Colors.black,
            shadowColor: Color(0xFF9c0c04),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 140,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 51,
                  width: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 23,
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            clubName,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C0C04)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                        width: 170,
                        child: Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: MinPriceAndMaxPersons(
                                minPrice: 110, maxPersons: 5)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
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
