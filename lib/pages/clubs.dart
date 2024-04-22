// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class clubsNearYouCard extends StatelessWidget {
  const clubsNearYouCard(this.clubName, {super.key});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Gesture Detected!')));
        },
        child: Card(
          elevation: 20,
          shadowColor: Colors.deepOrange,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
              Text(
                clubName,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ));
  }
}

class clubsList extends StatelessWidget {
  const clubsList(this.clubName, {super.key});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gesture Detected!')));
    });
  }
}






/*return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Gesture Detected!')));
        },
        child: Card(
          elevation: 20,
          child: Column(
            children: [
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                  ),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                ),
              ),
              Text(clubName)
            ],
          ),
        ));
*/