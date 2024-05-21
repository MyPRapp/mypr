import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
          ' $clubName',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9C0C04),
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
              size: 20,
              color: Colors.white30,
            ),
        if (stars % 1 == 0 && stars > 0 && stars <= 5)
          for (int i = 0; i < stars; i++)
            const Icon(
              Icons.star,
              size: 20,
              color: Color(0xFF9C0C04),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          for (int i = 1; i < stars; i++)
            const Icon(
              Icons.star,
              size: 20,
              color: Color(0xFF9C0C04),
            ),
        if (stars % 1 != 0 && stars > 0 && stars <= 5)
          const Icon(
            Icons.star_half,
            size: 20,
            color: Color(0xFF9C0C04),
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

  final int minPrice;
  final int maxPersons;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(
          Icons.monetization_on,
          color: Color(0xFF9C0C04),
        ),
        Text(
          ' $minPrice',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          ' | ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const Icon(
          Icons.account_circle,
          color: Color(0xFF9C0C04),
        ),
        Text(
          ' $maxPersons',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class DaysOpen extends StatelessWidget {
  const DaysOpen({
    super.key,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  @override
  Widget build(BuildContext context) {
    Color mondayColor = Colors.white24;
    Color tuesdayColor = Colors.white24;
    Color wednesdayColor = Colors.white24;
    Color thursdayColor = Colors.white24;
    Color fridayColor = Colors.white24;
    Color saturdayColor = Colors.white24;
    Color sundayColor = Colors.white24;

    if (monday == true) mondayColor = const Color(0xFF9c0c04);
    if (tuesday == true) tuesdayColor = const Color(0xFF9c0c04);
    if (wednesday == true) wednesdayColor = const Color(0xFF9c0c04);
    if (thursday == true) thursdayColor = const Color(0xFF9c0c04);
    if (friday == true) fridayColor = const Color(0xFF9c0c04);
    if (saturday == true) saturdayColor = const Color(0xFF9c0c04);
    if (sunday == true) sundayColor = const Color(0xFF9c0c04);

    return Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Row(
          children: [
            Text(
              'Δ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: mondayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Τ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: tuesdayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Τ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: wednesdayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Π',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: thursdayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Π',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: fridayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Σ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: saturdayColor),
            ),
            const Text(
              '/',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38),
            ),
            Text(
              'Κ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: sundayColor),
            ),
          ],
        ));
  }
}

class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool liked = false;

  void toggleButton() {
    setState(() {
      liked = !liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: toggleButton,
        child: SizedBox(
          height: 40,
          width: 60,
          child: liked
              ? const ImageIcon(
                      AssetImage("assets/icons/heart(liked)_icon.png"),
                      color: Color(0xFF9c0c04))
                  .animate(target: liked ? 1 : 0)
                  .scaleXY(duration: 400.ms, begin: 1.0, end: 1.1)
                  .then()
                  .scaleXY(duration: 400.ms, begin: 1.1, end: 1.0)
              : const ImageIcon(
                  AssetImage("assets/icons/heart(unliked)_icon.png"),
                  color: Color(0xFF9c0c04),
                ),
        ));
  }
}
