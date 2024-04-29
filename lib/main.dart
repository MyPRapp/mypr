// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:mypr/Pages/HomePage.dart';
import 'package:mypr/Pages/ProfilePage.dart';
import 'package:mypr/Widgets/BottomNavBar.dart';

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
