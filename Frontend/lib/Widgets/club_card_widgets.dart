import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../Providers/club_provider.dart';
import '../global_.components.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({
    super.key,
    required this.club,
    this.onRemove,
    this.big = false,
  });

  final ClubInfoStruct club;
  final VoidCallback? onRemove;
  final bool big;

  @override
  LikeButtonState createState() => LikeButtonState();
}

class LikeButtonState extends State<LikeButton> {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    final double size = widget.big ? 30 : 24;
    final clubProvider = context.watch<ClubProvider>();

    bool isLiked = clubProvider.isLiked(widget.club.clubID);

    return GestureDetector(
      onTap: () {
        clubProvider.toggleLike(widget.club.clubID);
        setState(() {
          tapped = true;
        });

        // Show SnackBar based on like status
        if (isLiked) {
          // If it was liked, show removal message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 1500),
                content: Text('Αφαιρέθηκε από τα αγαπημένα'),
              ),
            );
        } else {
          // If it was not liked, show added message
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                duration: Duration(milliseconds: 1500),
                content: Text('Προστέθηκε στα αγαπημένα'),
              ),
            );
        }

        // If onRemove is provided and the club is no longer liked, trigger the callback
        if (widget.onRemove != null &&
            !clubProvider.isLiked(widget.club.clubID)) {
          tapped = false;
          widget.onRemove!();
        }

        setState(() {
          tapped = false;
        });
      },
      child: SizedBox(
        height: 40,
        width: 40,
        child: isLiked
            ? Icon(Icons.favorite_rounded,
                    size: size, color: const Color.fromARGB(199, 156, 12, 4))
                .animate(target: tapped ? 1 : 0)
                .scaleXY(duration: 400.ms, begin: 1.0, end: 1.1)
                .then()
                .scaleXY(duration: 400.ms, begin: 1.1, end: 1.0)
            : Icon(Icons.favorite_border_rounded,
                size: size + 3, color: const Color.fromARGB(199, 156, 12, 4)),
      ),
    );
  }
}

class NameAndStars extends StatelessWidget {
  const NameAndStars({super.key, required this.clubName, required this.stars});

  final String clubName;
  final double stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          clubName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.start,
        ),
        RatingStars(
          stars: stars,
        ),
      ],
    );
  }
}

//RatingStars is used by NameAndStars
//if(stars <= 0 || stars > 5), then color = grey
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.stars});

  final double stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (stars <= 0 || stars > 5)
          for (int i = 0; i < 5; i++)
            const Icon(
              Icons.star_border_outlined,
              size: 18,
              color: Colors.white30,
            ),
        if (stars % 1 == 0 && stars > 0 && stars <= 5)
          for (int i = 0; i < stars; i++)
            const Icon(
              Icons.star,
              size: 18,
              color: Color.fromARGB(200, 156, 12, 4),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          for (int i = 1; i < stars; i++)
            const Icon(
              Icons.star,
              size: 18,
              color: Color.fromARGB(200, 156, 12, 4),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          const Icon(
            Icons.star_half,
            size: 18,
            color: Color.fromARGB(200, 156, 12, 4),
          ),
      ],
    );
  }
}

class MinPriceAndMaxPersons extends StatelessWidget {
  const MinPriceAndMaxPersons({
    super.key,
    required this.minPrice,
    required this.maxPersons,
  });

  final int minPrice, maxPersons;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.monetization_on_outlined,
          color: Color.fromARGB(197, 158, 158, 158),
        ),
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            ' $minPrice',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        if (minPrice < 0 || maxPersons < 0)
          const Text(
            '     ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        const Text(
          ' | ',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        const Icon(
          Icons.account_circle_outlined,
          color: Color.fromARGB(197, 158, 158, 158),
        ),
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            ' $maxPersons',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        if (minPrice < 0 || maxPersons < 0)
          const Text(
            ' ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(197, 158, 158, 158),
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
      required this.sunday});

  final bool monday, tuesday, wednesday, thursday, friday, saturday, sunday;

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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: mondayColor),
            ),
            Text(
              'Τ ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: tuesdayColor),
            ),
            Text(
              'Τ ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: wednesdayColor),
            ),
            Text(
              'Π ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: thursdayColor),
            ),
            Text(
              'Π ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: fridayColor),
            ),
            Text(
              'Σ ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: saturdayColor),
            ),
            Text(
              'Κ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: sundayColor),
            ),
          ],
        ));
  }
}
