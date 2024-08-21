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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: club));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0), // Apply border radius here
          child: Container(
            color: Colors.black,
            height: screenHeight / 2.2,
            width: screenWidth / 2.7,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: screenHeight / 8,
                      child: Image.network(
                        club.clubPhoto,
                        fit: BoxFit
                            .fill, // Ensure the image fits within the bounds
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: MinPriceAndMaxPersons(
                        minPrice: club.clubMinPrice,
                        maxPersons: club.clubMaxPersons,
                      ),
                    ),
                  ],
                ),
                LikeButton(
                  onRemove: onRemove,
                  club: club,
                ),
              ],
            ),
          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    print(club.clubPhoto);
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: club));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
        child: SizedBox(
          width: screenWidth - 20,
          height: 150,
          child: Card(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Row(children: [
              Stack(children: [
                SizedBox(
                  height: 150,
                  width: screenWidth - 300,
                  child: Image.network(
                    club.clubPhoto,
                    fit: BoxFit.cover,
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
                width: screenWidth - 150,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NameAndStars(
                                clubName: club.clubName,
                                stars: club.clubRating),
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
                              if (club.clubMinPrice >= 0 &&
                                  club.clubMaxPersons >= 0)
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
      ),
    );
  }
}
