import 'package:flutter/material.dart';

import 'pages/clubs.dart';

void main() => runApp(MyPR());

class MyPR extends StatelessWidget {
  MyPR({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MyPR',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Αναζήτηση'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Προφίλ')
            ],
            backgroundColor: const Color(0xFF9c0c04),
          ),
          body: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                      fit: BoxFit.fill)),
            ),
            ListView(controller: _scrollController, children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 10),
                child: Text(
                  'Καλησπέρα!',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
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
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 30),
                child: Text(
                  'Επιλογές κοντά σου',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              // ignore: sized_box_for_whitespace
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: clubNamesList.length,
                  itemBuilder: (_, index) =>
                      clubsNearYouCard(clubNamesList[index]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                child: Text(
                  'Όλα τα αποτελέσματα',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Card(
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Container(
                        height: 120,
                        width: 160,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/clubPhotos/Syko.jpg'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  Syko',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C0C04)),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(children: [
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
                                  ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(' 110',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text(
                                          '  |  ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        ),
                                        Icon(
                                          Icons.account_circle,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(
                                          ' 5',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      ]),
                                  Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Δ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Σ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Κ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Card(
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Container(
                        height: 120,
                        width: 160,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/clubPhotos/Akanthus.jpg'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  Akanthus',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C0C04)),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(children: [
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
                                  ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(' 120',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text(
                                          '  |  ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        ),
                                        Icon(
                                          Icons.account_circle,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(
                                          ' 5',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      ]),
                                  Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Δ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Σ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Κ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Card(
                  color: Colors.transparent,
                  margin: const EdgeInsets.only(left: 20, right: 10),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Container(
                        height: 120,
                        width: 160,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/clubPhotos/Toyroom.jpg'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  Syko',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF9C0C04)),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(children: [
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
                                  ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(' 100',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        Text(
                                          '  |  ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey),
                                        ),
                                        Icon(
                                          Icons.account_circle,
                                          color: Color(0xFF9C0C04),
                                        ),
                                        Text(
                                          ' 5',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        )
                                      ]),
                                  Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Δ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Τ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          const Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF9C0C04)),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Π',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Σ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                          Text(
                                            'Κ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[500]),
                                          ),
                                          const Text(
                                            '/',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Card(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/clubPhotos/Akanthus.jpg'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                        width: 390,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  Akanthus',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(children: [
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          color: Colors.black,
                                        ),
                                        Text(' 120',
                                            style: TextStyle(
                                                fontSize: 18,
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                  Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Δ/Τ/Τ/Π/Π/Σ/Κ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          )
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Card(
                  margin: const EdgeInsets.only(left: 50, right: 50),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage('assets/clubPhotos/Toyroom.jpg'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 70,
                        width: 390,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '  Toyroom',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    textAlign: TextAlign.start,
                                  ),
                                  Row(children: [
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star,
                                      size: 20,
                                    ),
                                    Icon(
                                      Icons.star_half,
                                      size: 20,
                                    )
                                  ]),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          color: Colors.black,
                                        ),
                                        Text(' 100',
                                            style: TextStyle(
                                                fontSize: 18,
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
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        )
                                      ]),
                                  Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          Text(
                                            'Δ/Τ/Τ/Π/Π/Σ/Κ',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          )
                                        ],
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),*/
            ]),
          ]),
        ));
  }
}

List clubNamesList = [
  'Lohan',
  'Blast',
  'Toyroom',
  'Akanthus',
  'Syko',
  'Boutique'
];
