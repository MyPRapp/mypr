import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';

import '../global_components.dart';

class BigClubCard extends StatefulWidget {
  const BigClubCard(
      {super.key,
      required this.club,
      required this.screenHeight,
      required this.screenWidth});

  final ClubInfoStruct club;
  final double screenHeight;
  final double screenWidth;

  @override
  State<BigClubCard> createState() => _BigClubCardState();
}

class _BigClubCardState extends State<BigClubCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _scale = 1.0; // Animate to full size
      });
    });
  }

  List<bool> _daysOpen(String availabilityInBytes) {
    return availabilityInBytes.split('').map((char) => char == '1').toList();
  }

  String processString(String input) {
    // Check if there are any commas in the string
    if (!input.contains(',')) {
      return input;
    }

    // Split the string by commas
    List<String> parts = input.split(',');

    // Get the substring after the last comma and trim whitespaces
    String result = parts.last.trim();

    return result;
  }

  double _scale = 0.6;
  @override
  Widget build(BuildContext context) {
    final daysOpen = _daysOpen(widget.club.clubAvailability);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: widget.club));
      },
      child: Padding(
        padding: EdgeInsets.only(
            bottom: screenHeight * 0.03,
            left: screenWidth * 0.02,
            right: screenWidth * 0.02),
        child: Container(
          width: screenWidth * 0.96,
          height: screenHeight / 6,
          decoration: BoxDecoration(
              color: const Color.fromARGB(57, 0, 0, 0),
              borderRadius: BorderRadius.circular(7.5)),
          child: Row(
            children: [
              Stack(
                children: [
                  AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(7.5),
                          topLeft: Radius.circular(7.5)),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.17,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: widget.club.localPhotoPath.isNotEmpty
                            ? Image(
                                fit: BoxFit.fill,
                                image:
                                    FileImage(File(widget.club.localPhotoPath)),
                              )
                            : widget.club.clubPhoto.isNotEmpty
                                ? Image.network(
                                    widget.club.clubPhoto,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF9C0C04),
                                          backgroundColor: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF9C0C04),
                                      backgroundColor: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    child: LikeButton(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      club: widget.club,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenHeight * 0.01),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NameAndStars(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            clubName: widget.club.clubName,
                            stars: widget.club.clubRating,
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.006),
                            child: Text(
                              processString(widget.club.clubLocation),
                              style: TextStyle(
                                fontSize: screenHeight * 0.015,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 102, 102, 102),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MinPriceAndMaxPersons(
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
                              minPrice: widget.club.clubMinPrice,
                              maxPersons: widget.club.clubMaxPersons,
                            ),
                            DaysOpen(
                              monday: daysOpen[0],
                              tuesday: daysOpen[1],
                              wednesday: daysOpen[2],
                              thursday: daysOpen[3],
                              friday: daysOpen[4],
                              saturday: daysOpen[5],
                              sunday: daysOpen[6],
                              screenHeight: screenHeight,
                              screenWidth: screenWidth,
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
    );
  }
}
/* 
class SmallClubCard extends StatefulWidget {
  const SmallClubCard({
    super.key,
    required this.club,
  });

  final ClubInfoStruct club;

  @override
  State<SmallClubCard> createState() => _SmallClubCardState();
}

class _SmallClubCardState extends State<SmallClubCard> {
  late Future<ImageProvider?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() {
    setState(() {
      // Load club photo from network first, then fallback to local storage if needed
      _imageFuture = context
          .read<ClubProvider>()
          .loadImageFromFileOrNetwork(widget.club.clubID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: widget.club));
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
                    FutureBuilder<ImageProvider?>(
                      future: _imageFuture,
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
                          widget.club.clubName,
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
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        minPrice: widget.club.clubMinPrice,
                        maxPersons: widget.club.clubMaxPersons,
                      ),
                    ),
                  ],
                ),
                LikeButton(
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                  club: widget.club,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */