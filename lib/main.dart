// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names, must_be_immutable, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mypr/Pages/HomePage.dart';

void main() => runApp(const MyPR());

class MyPR extends StatelessWidget {
  const MyPR({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        title: 'MyPR',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF000000),
          bottomNavigationBar: BottomNavBar(),
          body: HomePage(),
        ));
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: Colors.black,
          ),
          label: 'Αρχική',
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black), label: 'Αναζήτηση'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black), label: 'Προφίλ')
      ],
      backgroundColor: const Color(0xFF9c0c04),
    );
  }
}
