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
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: Card(
            margin: const EdgeInsets.only(bottom: 30),
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 170,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 170,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                        width: 170,
                        child: Text(
                          '  $clubName',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                        width: 170,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Row(children: [
                            Icon(
                              Icons.monetization_on,
                              color: Colors.black,
                            ),
                            Text(' 110',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            Text(
                              '  |  ',
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(
                              Icons.account_circle,
                              color: Colors.black,
                            ),
                            Text(
                              ' 5',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )
                          ]),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
