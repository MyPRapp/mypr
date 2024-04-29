// ignore_for_file: unused_import
import 'package:flutter/material.dart';

class NameAndStars extends StatelessWidget {
  const NameAndStars({super.key, required this.clubName});

  final String clubName;

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
              color: Color(0xFF9C0C04)),
          textAlign: TextAlign.start,
        ),
        const RatingStars(),
      ],
    );
  }
}

class RatingStars extends StatelessWidget {
  const RatingStars({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Icon(
        Icons.star,
        size: 20,
        color: Color(0xFF9C0C04),
      ),
      Icon(
        Icons.star,
        size: 20,
        color: Color(0xFF9C0C04),
      ),
      Icon(
        Icons.star,
        size: 20,
        color: Color(0xFF9C0C04),
      ),
      Icon(
        Icons.star,
        size: 20,
        color: Color(0xFF9C0C04),
      ),
      Icon(
        Icons.star_half,
        size: 20,
        color: Color(0xFF9C0C04),
      )
    ]);
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
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      const Icon(
        Icons.monetization_on,
        color: Color(0xFF9C0C04),
      ),
      Text(' $minPrice',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      const Text(
        ' | ',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
      const Icon(
        Icons.account_circle,
        color: Color(0xFF9C0C04),
      ),
      Text(
        ' $maxPersons',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      )
    ]);
  }
}

class DaysOpen extends StatelessWidget {
  const DaysOpen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.only(right: 5),
        child: Row(
          children: [
            Text(
              'Δ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white24),
            ),
            Text(
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
                  color: Colors.white24),
            ),
            Text(
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
                  color: Colors.white24),
            ),
            Text(
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
                  color: Colors.white24),
            ),
            Text(
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
                  color: Color(0xFF9C0C04)),
            ),
            Text(
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
                  color: Color(0xFF9C0C04)),
            ),
            Text(
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
                  color: Color(0xFF9C0C04)),
            ),
          ],
        ));
  }
}

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: TextField(
        style: const TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        cursorColor: Colors.black,
        cursorHeight: 25,
        cursorWidth: 2,
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: const EdgeInsets.all(8),
          filled: true,
          fillColor: Colors.white70,
          hoverColor: Colors.black,
          hintText: 'Αναζήτηση',
          hintStyle: const TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
