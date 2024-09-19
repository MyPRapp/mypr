import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/club_provider.dart';
import '../global_components.dart';

class LikeButton extends StatefulWidget {
  const LikeButton(
      {super.key,
      required this.club,
      this.big = false,
      required this.screenHeight,
      required this.screenWidth});

  final ClubInfoStruct club;
  final bool big;
  final double screenHeight;
  final double screenWidth;
  @override
  LikeButtonState createState() => LikeButtonState();
}

class LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    final double size = widget.big
        ? widget.screenHeight * widget.screenWidth * 0.00012
        : widget.screenHeight * widget.screenWidth * 0.00009;
    final clubProvider = context.watch<ClubProvider>();

    bool isLiked = clubProvider.isLiked(widget.club.clubID);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          tapped = true;
        });

        clubProvider.toggleLike(widget.club.clubID);
      },
      child: SizedBox(
        height: widget.screenWidth * 0.1,
        width: widget.screenWidth * 0.1,
        child: isLiked
            ? Icon(Icons.favorite_rounded,
                size: size, color: const Color.fromARGB(199, 156, 12, 4))
            : Icon(Icons.favorite_border_rounded,
                size: size, color: const Color.fromARGB(199, 156, 12, 4)),
      ),
    );
  }
}

class NameAndStars extends StatelessWidget {
  const NameAndStars(
      {super.key,
      required this.clubName,
      required this.stars,
      required this.screenHeight,
      required this.screenWidth});

  final String clubName;
  final double stars;
  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          clubName,
          style: TextStyle(
            fontSize: screenHeight * 0.022,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.start,
        ),
        RatingStars(
          stars: stars,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        ),
      ],
    );
  }
}

//RatingStars is used by NameAndStars
//if(stars <= 0 || stars > 5), then color = grey
class RatingStars extends StatelessWidget {
  const RatingStars(
      {super.key,
      required this.stars,
      required this.screenHeight,
      required this.screenWidth});

  final double stars;
  final double screenHeight;
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (stars <= 0 || stars > 5)
          for (int i = 0; i < 5; i++)
            Icon(
              Icons.star_border_outlined,
              size: screenHeight * screenWidth * 0.000065,
              color: Colors.white30,
            ),
        if (stars % 1 == 0 && stars > 0 && stars <= 5)
          for (int i = 0; i < stars; i++)
            Icon(
              Icons.star,
              size: screenHeight * screenWidth * 0.000065,
              color: const Color.fromARGB(200, 156, 12, 4),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          for (int i = 1; i < stars; i++)
            Icon(
              Icons.star,
              size: screenHeight * screenWidth * 0.000065,
              color: const Color.fromARGB(200, 156, 12, 4),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          Icon(
            Icons.star_half,
            size: screenHeight * screenWidth * 0.000065,
            color: const Color.fromARGB(200, 156, 12, 4),
          ),
      ],
    );
  }
}

class MinPriceAndMaxPersons extends StatelessWidget {
  const MinPriceAndMaxPersons(
      {super.key,
      required this.minPrice,
      required this.maxPersons,
      required this.screenHeight,
      required this.screenWidth});

  final int minPrice, maxPersons;
  final double screenHeight;
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          size: screenHeight * 0.03 + screenWidth * 0.01,
          Icons.monetization_on_outlined,
          color: const Color.fromARGB(197, 158, 158, 158),
        ),
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            ' $minPrice',
            style: TextStyle(
              fontSize: screenHeight * 0.02 + screenWidth * 0.004,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        if (minPrice < 0 || maxPersons < 0)
          Text(
            '     ',
            style: TextStyle(
              fontSize: screenHeight * 0.02 + screenWidth * 0.004,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        Text(
          ' | ',
          style: TextStyle(
              fontSize: screenHeight * 0.02 + screenWidth * 0.004,
              fontWeight: FontWeight.w500,
              color: Colors.grey),
        ),
        Icon(
          size: screenHeight * 0.03 + screenWidth * 0.01,
          Icons.account_circle_outlined,
          color: const Color.fromARGB(197, 158, 158, 158),
        ),
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            ' $maxPersons',
            style: TextStyle(
              fontSize: screenHeight * 0.02 + screenWidth * 0.004,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        if (minPrice < 0 || maxPersons < 0)
          Text(
            ' ',
            style: TextStyle(
              fontSize: screenHeight * 0.02 + screenWidth * 0.004,
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
      ],
    );
  }
}

class DaysOpen extends StatelessWidget {
  const DaysOpen(
      {super.key,
      required this.monday,
      required this.tuesday,
      required this.wednesday,
      required this.thursday,
      required this.friday,
      required this.saturday,
      required this.sunday,
      required this.screenHeight,
      required this.screenWidth});

  final bool monday, tuesday, wednesday, thursday, friday, saturday, sunday;
  final double screenHeight;
  final double screenWidth;
  @override
  Widget build(BuildContext context) {
    Color mondayColor = Colors.white24;
    Color tuesdayColor = Colors.white24;
    Color wednesdayColor = Colors.white24;
    Color thursdayColor = Colors.white24;
    Color fridayColor = Colors.white24;
    Color saturdayColor = Colors.white24;
    Color sundayColor = Colors.white24;

    Color dayColor = Colors.white;
    if (monday == true) mondayColor = dayColor;
    if (tuesday == true) tuesdayColor = dayColor;
    if (wednesday == true) wednesdayColor = dayColor;
    if (thursday == true) thursdayColor = dayColor;
    if (friday == true) fridayColor = dayColor;
    if (saturday == true) saturdayColor = dayColor;
    if (sunday == true) sundayColor = dayColor;

    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Row(
          children: [
            Text(
              'Δ ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: mondayColor),
            ),
            Text(
              'Τ ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: tuesdayColor),
            ),
            Text(
              'Τ ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: wednesdayColor),
            ),
            Text(
              'Π ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: thursdayColor),
            ),
            Text(
              'Π ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: fridayColor),
            ),
            Text(
              'Σ ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: saturdayColor),
            ),
            Text(
              'Κ',
              style: TextStyle(
                  fontSize: screenHeight * 0.016 + screenWidth * 0.001,
                  fontWeight: FontWeight.w500,
                  color: sundayColor),
            ),
          ],
        ));
  }
}
