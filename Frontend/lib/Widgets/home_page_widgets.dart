import 'dart:typed_data';

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
      // Load club photo from file system instead of network
      _imageFuture = _loadImageFromFile(widget.club.clubID);
    });
  }

  Future<ImageProvider?> _loadImageFromFile(int clubID) async {
    Uint8List? imageBytes =
        await context.read<ClubProvider>().loadClubPhotoFromFile(clubID);

    if (imageBytes != null) {
      return MemoryImage(imageBytes);
    } else {
      // Return a default image or null if the image is not found
      return const AssetImage('assets/images/default_club_image.png');
    }
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
                        minPrice: widget.club.clubMinPrice,
                        maxPersons: widget.club.clubMaxPersons,
                      ),
                    ),
                  ],
                ),
                LikeButton(
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
  const BigClubCard({
    super.key,
    required this.club,
  });
  final ClubInfoStruct club;

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

  void _loadImage() {
    setState(() {
      // Load club photo from the file system
      _imageFuture = _loadImageFromFile(widget.club.clubID);
    });
  }

  Future<ImageProvider?> _loadImageFromFile(int clubID) async {
    Uint8List? imageBytes =
        await context.read<ClubProvider>().loadClubPhotoFromFile(clubID);

    if (imageBytes != null) {
      return MemoryImage(imageBytes);
    } else {
      // Return a default image or null if the image is not found
      return const AssetImage('assets/images/default_club_image.png');
    }
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
      onTap: () {
        AutoRouter.of(context).push(ReservationRoute(club: widget.club));
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
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        child: FutureBuilder<ImageProvider?>(
                          future: _imageFuture,
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
                          club: widget.club,
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
                                clubName: widget.club.clubName,
                                stars: widget.club.clubRating,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  widget.club.clubLocation,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MinPriceAndMaxPersons(
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
    );
  }
}
