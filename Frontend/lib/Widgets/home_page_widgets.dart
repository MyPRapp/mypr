import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmallClubCard extends StatelessWidget {
  const SmallClubCard({
    super.key,
    required this.club,
    this.onRemove,
  });

  final ClubInfoStruct club;
  final VoidCallback? onRemove;

  Future<ImageProvider> _loadImage() async {
    try {
      // Try to load image from SharedPreferences first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('club_image_${club.clubID}');
      if (base64Image != null) {
        return MemoryImage(base64Decode(base64Image));
      }

      // If not available, load image from network
      final image = NetworkImage(club.clubPhoto);

      // Try to fetch the image from the network
      return image;
    } catch (e) {
      // If all fails, return a default image
      return const AssetImage('assets/images/default_club_image.png');
    }
  }

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
          borderRadius: BorderRadius.circular(7),
          child: Container(
            color: Colors.black,
            height: screenHeight / 2.2,
            width: screenWidth / 2.7,
            child: Stack(
              children: [
                Column(
                  children: [
                    FutureBuilder<ImageProvider>(
                      future: _loadImage(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return SizedBox(
                            height: screenHeight / 8,
                            child: Image(
                              image: snapshot.data!,
                              fit: BoxFit.fill,
                            ),
                          );
                        } else {
                          return SizedBox(
                            height: screenHeight / 8,
                            child: const CircularProgressIndicator(),
                          );
                        }
                      },
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

  Future<ImageProvider> _loadImage() async {
    try {
      // Try to load image from SharedPreferences first
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('club_image_${club.clubID}');
      if (base64Image != null) {
        return MemoryImage(base64Decode(base64Image));
      }

      // If not available, load image from network
      final image = NetworkImage(club.clubPhoto);

      // Try to fetch the image from the network
      return image;
    } catch (e) {
      // If all fails, return a default image
      return const AssetImage('assets/images/default_club_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysOpen = _daysOpen(club.clubAvailability);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: club));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
        child: SizedBox(
          width: screenWidth - 20,
          height: screenHeight * 0.14,
          child: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(0, 0, 0, 0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SizedBox(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                          child: FutureBuilder<ImageProvider>(
                            future: _loadImage(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                                return SizedBox(
                                  height: screenHeight * 0.17,
                                  width: screenWidth * 0.3,
                                  child: Image(
                                    image: snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return SizedBox(
                                  height: screenHeight * 0.17,
                                  width: screenWidth * 0.3,
                                  child: const CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          child: LikeButton(
                            onRemove: onRemove,
                            club: club,
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                NameAndStars(
                                  clubName: club.clubName,
                                  stars: club.clubRating,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    club.clubLocation,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromARGB(255, 102, 102, 102),
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
