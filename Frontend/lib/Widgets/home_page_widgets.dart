import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../global_components.dart';

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
      _imageFuture = context.read<ClubProvider>().loadImageFromFileOrNetwork(
          widget.club.clubID, widget.club.clubPhoto);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
  late Future<ImageProvider?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _loadImage(); // Load the image when the widget is initialized
  }

  @override
  void didUpdateWidget(BigClubCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the club has changed to reload the image
    if (oldWidget.club.clubID != widget.club.clubID) {
      _loadImage();
    }
  }

  void _loadImage() {
    setState(() {
      // Load club photo from the network first, fallback to local storage
      _imageFuture = context.read<ClubProvider>().loadImageFromFileOrNetwork(
          widget.club.clubID, widget.club.clubPhoto);
    });
  }

  List<bool> _daysOpen(String availabilityInBytes) {
    return availabilityInBytes.split('').map((char) => char == '1').toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysOpen = _daysOpen(widget.club.clubAvailability);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: widget.club));
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: screenHeight * 0.03),
        child: SizedBox(
          width: screenWidth,
          height: screenHeight / 6,
          child: Row(
            children: [
              SizedBox(width: screenWidth * 0.02),
              Stack(
                children: [
                  FutureBuilder<ImageProvider?>(
                    key: ValueKey(
                        widget.club.clubID), // Use a unique key for each club
                    future: _imageFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(7.5),
                          child: SizedBox(
                            height: screenHeight * 0.17,
                            width: screenWidth * 0.3,
                            child: Image(
                              image: snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      } else {
                        return SizedBox(
                          height: screenHeight * 0.17,
                          width: screenWidth * 0.3,
                          child: const CircularProgressIndicator(
                            color: Color(0xFF9C0C04),
                            strokeCap: StrokeCap.square,
                          ),
                        );
                      }
                    },
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
                              widget.club.clubLocation,
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
