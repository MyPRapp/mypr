import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

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
    this.onRemove,
  });

  final double stars;
  final VoidCallback? onRemove;
  final String clubName, address;
  final int minPrice, maxPersons;
  final bool monday, tuesday, wednesday, thursday, friday, saturday, sunday;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            AutoRouter.of(context).push(ReservationRoute(clubName: clubName));
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Card(
              color: Colors.transparent,
              margin: const EdgeInsets.only(left: 20),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(
                    height: 140,
                    width: 120,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(
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
                                color: Colors.white,
                              ),
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
                  )
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 0),
          child: LikeButton(
            onRemove: onRemove,
            clubName: clubName,
          ),
        ),
      ],
    );
  }
}

class SmallClubCard extends StatelessWidget {
  const SmallClubCard({
    super.key,
    required this.clubName,
    required this.minPrice,
    required this.maxPersons,
    this.onRemove,
  });

  final String clubName;
  final int minPrice;
  final int maxPersons;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            AutoRouter.of(context).push(ReservationRoute(clubName: clubName));
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
                        SizedBox(
                          height: 20,
                          width: 170,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: MinPriceAndMaxPersons(
                              minPrice: minPrice,
                              maxPersons: maxPersons,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5, top: 5),
          child: LikeButton(
            onRemove: onRemove,
            clubName: clubName,
          ),
        ),
      ],
    );
  }
}

// LikeButton widget
class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.clubName,
    this.onRemove,
  });

  final String clubName;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    ClubProvider clubProvider = context.watch<ClubProvider>();
    final club = clubProvider.getClubByName(clubName);
    return GestureDetector(
      onTap: () {
        context.read<ClubProvider>().toggleLike(clubName);
        if (onRemove != null &&
            !context.read<ClubProvider>().isLiked(clubName)) {
          onRemove!();
        }
        if (club.clubIsLiked) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                duration: Durations.medium4,
                content: Text('Αφαιρέθηκε από τα αγαπημένα')),
          );
          if (onRemove != null) {
            onRemove!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                duration: Durations.medium4,
                content: Text('Προστέθηκε στα αγαπημένα')),
          );
        }
      },
      child: SizedBox(
        height: 40,
        width: 60,
        child: club.clubIsLiked
            ? const ImageIcon(AssetImage("assets/icons/heart(liked)_icon.png"),
                    color: Color(0xFF9c0c04))
                .animate(target: club.clubIsLiked ? 1 : 0)
                .scaleXY(duration: 400.ms, begin: 1.0, end: 1.1)
                .then()
                .scaleXY(duration: 400.ms, begin: 1.1, end: 1.0)
            : const ImageIcon(
                AssetImage("assets/icons/heart(unliked)_icon.png"),
                color: Color(0xFF9c0c04),
              ),
      ),
    );
  }
}

TextStyle textStyle1() {
  return const TextStyle(
      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white);
}
