import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Widgets/club_card_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../Globals/classes.dart';

class BigClubCard extends StatefulWidget {
  const BigClubCard(
      {super.key,
      required this.club,
      required this.screenHeight,
      required this.screenWidth});

  final Club club;
  final double screenHeight;
  final double screenWidth;

  @override
  State<BigClubCard> createState() => _BigClubCardState();
}

class _BigClubCardState extends State<BigClubCard> {
  double _scale = 0;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        List<Catalogue> catalogues = context
            .read<ClubProvider>()
            .getCataloguesByClubID(widget.club.clubID);

        if (catalogues[0].price != '0' &&
            catalogues[1].price != '0' &&
            catalogues[2].price != '0') {
          AutoRouter.of(context).push(
              ReservationRoute(club: widget.club, catalogues: catalogues));
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
                          width: widget.screenWidth * 0.3,
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
                            openDays: widget.club.clubAvailableDays,
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

void showPointsReminderDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(
              255, 29, 29, 29), // Dark background for a sleek look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r), // Smooth rounded edges
          ),
          title: Text(
            "Υπενθύμιση Πόντων",
            style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 19.sp,
              color: const Color.fromARGB(
                  255, 255, 0, 0), // Red accent color for contrast
            ),
          ),
          content: Text(
            "Δημιούργησε καινούργιο προφίλ και χρησιμοποίησε τους πόντους σου για εκπτώσεις σε φιάλες!",
            style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14.sp,
              color: Colors.grey[300], // Light grey for better readability
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // White text for visibility
              ),
              child: Text("Κλείσιμο",
                  style: TextStyle(
                    fontSize: 13.sp,
                  )),
            ),
          ],
        ),
      );
    },
  );
}
