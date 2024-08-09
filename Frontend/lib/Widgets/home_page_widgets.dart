import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';

class SmallClubCard extends StatelessWidget {
  const SmallClubCard({
    super.key,
    required this.club,
    this.onRemove,
  });

  final ClubInfoStruct club;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: club));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
        child: Card(
          margin: const EdgeInsets.only(bottom: 30),
          color: Colors.black,
          shadowColor: const Color(0xFF9c0c04),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            Stack(children: [
              SizedBox(
                height: 100,
                width: 140,
                child: Image.network(
                    'http://127.0.0.1:8000/media/club_photos/${club.clubName}.jpg'),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: LikeButton(
                  onRemove: onRemove,
                  club: club,
                ),
              ),
            ]),
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
                          club.clubName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 170,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: MinPriceAndMaxPersons(
                          minPrice: club.clubMinPrice,
                          maxPersons: club.clubMaxPersons,
                        ),
                      ),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class BigClubCard extends StatelessWidget {
  const BigClubCard({
    super.key,
    required this.club,
    this.onRemove,
  });
  List<bool> _daysOpen(String availabilityInBytes) {
    return availabilityInBytes.split('').map((char) => char == '1').toList();
  }

  final ClubInfoStruct club;
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) {
    final daysOpen = _daysOpen(club.clubAvailability);
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: club));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Card(
          color: Colors.transparent,
          margin: const EdgeInsets.only(left: 20),
          clipBehavior: Clip.antiAlias,
          child: Row(children: [
            Stack(children: [
              Container(
                height: 140,
                width: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/clubPhotos/${club.clubName}.jpg'),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                child: LikeButton(
                  onRemove: onRemove,
                  club: club,
                ),
              ),
            ]),
            SizedBox(
              height: 120,
              width: 230,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NameAndStars(
                              clubName: club.clubName, stars: club.clubRating),
                          Text(
                            '  ${club.clubLocation}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ]),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MinPriceAndMaxPersons(
                              minPrice: club.clubMinPrice,
                              maxPersons: club.clubMaxPersons,
                            ),
                            DaysOpen(
                              monday: daysOpen[0],
                              tuesday: daysOpen[1],
                              wednesday: daysOpen[2],
                              thursday: daysOpen[3],
                              friday: daysOpen[4],
                              saturday: daysOpen[5],
                              sunday: daysOpen[6],
                            ),
                          ]),
                    ),
                  ]),
            )
          ]),
        ),
      ),
    );
  }
}
