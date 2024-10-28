import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../Globals/structs.dart';

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

  double _scale = 0;
  @override
  Widget build(BuildContext context) {
    final screenWidth = widget.screenWidth;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        List<CatalogueInfoStruct> catalogues = context
            .read<ClubProvider>()
            .getCataloguesByClubID(widget.club.clubID);

        if (context.read<GlobalStateProvider>().isAuthenticated) {
          if (context.read<UserProvider>().userDetails.userID > 0) {
            if (catalogues[0].price != '0' &&
                catalogues[1].price != '0' &&
                catalogues[2].price != '0') {
              AutoRouter.of(context).push(
                  ReservationRoute(club: widget.club, catalogues: catalogues));
            }
          }
        } else {
          if (catalogues[0].price != '0' &&
              catalogues[1].price != '0' &&
              catalogues[2].price != '0') {
            AutoRouter.of(context).push(
                ReservationRoute(club: widget.club, catalogues: catalogues));
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 30.h,
        ),
        child: Container(
          height: 140.h,
          decoration: BoxDecoration(
              color: const Color.fromARGB(57, 0, 0, 0),
              borderRadius: BorderRadius.circular(10.r)),
          child: Row(
            children: [
              Stack(
                children: [
                  AnimatedScale(
                    scale: _scale,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10.r),
                          topLeft: Radius.circular(10.r)),
                      child: SizedBox(
                          height: 140.h,
                          width: screenWidth * 0.3,
                          child: buildImage()),
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
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(5.sp),
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
                          SizedBox(height: 3.h),
                          Text(
                            processString(widget.club.clubLocation),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 102, 102, 102),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MinPriceAndMaxPersons(
                            minPrice: widget.club.clubMinPrice,
                            maxPersons: widget.club.clubMaxPersons,
                          ),
                          DaysOpen(
                            openDays: widget.club.clubAvailability,
                          ),
                        ],
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

  Widget buildImage() {
    return widget.club.localPhotoPath.isNotEmpty
        ? Image(
            fit: BoxFit.fill,
            image: FileImage(File(widget.club.localPhotoPath)),
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              // If loading from the file fails, attempt to load from the network
              return loadNetworkImage();
            },
          )
        : loadNetworkImage();
  }

  Widget loadNetworkImage() {
    if (widget.club.clubPhoto.isNotEmpty) {
      return Image.network(
        widget.club.clubPhoto,
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          // If loading from the network fails, show the loading indicator
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      // If there's no image path, just show a loading indicator
      return const Center(
        child: CircularProgressIndicator(
          color: appRedColor,
          backgroundColor: Colors.black,
          strokeWidth: 2,
        ),
      );
    }
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
                            color:appRedColor,
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