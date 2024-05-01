import 'package:flutter/material.dart';
import 'package:mypr/Pages/ReservationPage.dart';
import 'package:mypr/Widgets/ClubCardWidgets.dart';

class BigClubCard extends StatelessWidget {
  const BigClubCard({
    super.key,
    required this.clubName,
    required this.address,
    required this.stars,
    required this.minPrice,
    required this.maxPersons,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final String clubName;
  final String address;
  final double stars;
  final int minPrice;
  final int maxPersons;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReservationPage(
              clubName: clubName,
            ),
          ),
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
                maxPersons: maxPersons,
                monday: monday,
                tuesday: tuesday,
                wednesday: wednesday,
                thursday: thursday,
                friday: friday,
                saturday: saturday,
                sunday: sunday,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BigClubCardInfo extends StatelessWidget {
  const BigClubCardInfo({
    super.key,
    required this.clubName,
    required this.address,
    required this.stars,
    required this.minPrice,
    required this.maxPersons,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final String clubName;
  final String address;
  final double stars;
  final int minPrice;
  final int maxPersons;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

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
              NameAndStars(clubName: clubName, stars: stars),
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
                  minPrice: minPrice,
                  maxPersons: maxPersons,
                ),
                DaysOpen(
                  monday: monday,
                  tuesday: tuesday,
                  wednesday: wednesday,
                  thursday: thursday,
                  friday: friday,
                  saturday: saturday,
                  sunday: sunday,
                ),
              ],
            ),
          ),
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
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
        child: Card(
          margin: const EdgeInsets.only(bottom: 30),
          color: Colors.black,
          shadowColor: const Color(0xFF9c0c04),
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
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                      width: 170,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5),
                        child:
                            MinPriceAndMaxPersons(minPrice: 110, maxPersons: 5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
