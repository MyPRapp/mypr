// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mypr/pages/page2.dart';

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
          padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
          child: Card(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 67,
                  width: 200,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 200,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.white),
                              elevation: WidgetStateProperty.all(0),
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(
                              '  $clubName',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            onPressed: () {
                              if (clubName == 'Syko')
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SykoRoute()),
                                );
                              if (clubName == 'Blast')
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const BlastRoute()),
                                );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 47,
                        width: 200,
                        child: Row(children: [
                          Icon(
                            Icons.monetization_on,
                            color: Color(0xff9c0c04),
                          ),
                          Text(' 110',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          Text(
                            '    |    ',
                            style: TextStyle(fontSize: 15),
                          ),
                          Icon(
                            Icons.account_circle,
                            color: Color(0xff9c0c04),
                          ),
                          Text(
                            ' 5',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          )
                        ]),
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
