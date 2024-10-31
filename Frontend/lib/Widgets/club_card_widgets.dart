import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:provider/provider.dart';

import '../Globals/structs.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.club});

  final ClubInfoStruct club;
  @override
  LikeButtonState createState() => LikeButtonState();
}

class LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool tapped = false;

  @override
  Widget build(BuildContext context) {
    final likeProvider = context.watch<LikedClubsProvider>();
    bool isLiked = likeProvider.isLiked(widget.club.clubID);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        setState(() {
          tapped = true;
        });

        likeProvider.toggleLike(widget.club.clubID);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 7, top: 7),
        child: SizedBox(
          height: 30.sp,
          width: 30.sp,
          child: AnimatedSwitcher(
            duration:
                const Duration(milliseconds: 300), // Duration of the animation
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: isLiked
                ? Image.asset(
                    height: 25.sp,
                    width: 25.sp,
                    'assets/icons/heart_filled.png',
                    key: const ValueKey('filledHeart'),
                    color: const Color.fromARGB(105, 136, 136, 136),
                  )
                : Image.asset(
                    height: 25.sp,
                    width: 25.sp,
                    'assets/icons/heart_outline.png',
                    key: const ValueKey('outlineHeart'),
                    color: const Color.fromARGB(179, 136, 136, 136),
                  ),
          ),
        ),
      ),
    );
  }
}

class NameAndStars extends StatelessWidget {
  const NameAndStars({
    super.key,
    required this.clubName,
    required this.stars,
  });

  final String clubName;
  final double stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          clubName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.start,
        ),
        if (stars > 0)
          RatingStars(
            stars: stars,
          ),
      ],
    );
  }
}

//RatingStars is used by NameAndStars
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.stars});

  final double stars;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(
        Icons.star,
        size: 20.sp,
        color: const Color.fromARGB(200, 156, 12, 4),
      ),
      Text(
        '($stars)',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13.sp,
        ),
      )
    ]);
  }
}

class MinPriceAndMaxPersons extends StatelessWidget {
  const MinPriceAndMaxPersons(
      {super.key, required this.minPrice, required this.maxPersons});

  final int minPrice, maxPersons;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            '$minPrice',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
        SizedBox(
          height: 30.h,
          width: 16.w,
          child: Image.asset(
            'assets/icons/euro.png',
            fit: BoxFit.scaleDown,
            color: const Color.fromARGB(197, 158, 158, 158),
          ),
        ),
        Text(
          ' | ',
          style: TextStyle(
              fontSize: 20.sp, fontWeight: FontWeight.w400, color: Colors.grey),
        ),
        SizedBox(
          height: 40.h,
          width: 30.w,
          child: Image.asset(
            'assets/icons/person_with_circle.png',
            fit: BoxFit.scaleDown,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        if (minPrice >= 0 && maxPersons >= 0)
          Text(
            '$maxPersons',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w400,
              color: const Color.fromARGB(197, 158, 158, 158),
            ),
          ),
      ],
    );
  }
}

class DaysOpen extends StatelessWidget {
  const DaysOpen({
    super.key,
    required this.openDays,
  });

  final String openDays; // Expecting a string of 7 characters (0s and 1s)
  @override
  Widget build(BuildContext context) {
    // Ensure the openDays string is exactly 7 characters long
    if (openDays.length != 7) {
      throw ArgumentError(
          'openDays must be a string of 7 characters (0s and 1s)');
    }

    // Define day abbreviations and corresponding colors based on the openDays string
    const dayAbbreviations = [
      'Δ ',
      'Τ ',
      'Τ ',
      'Π ',
      'Π ',
      'Σ ',
      'Κ'
    ]; // Monday to Sunday
    final colors = openDays.split('').map((char) {
      return char == '1'
          ? Colors.white
          : Colors.white24; // Use white for open, white24 for closed
    }).toList();

    return Row(
      children: List.generate(dayAbbreviations.length, (index) {
        return Text(
          dayAbbreviations[index],
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: colors[index] == Colors.white24
                ? FontWeight.w900
                : FontWeight.w100,
            color: colors[index],
          ),
        );
      }),
    );
  }
}
