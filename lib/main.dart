import 'package:flutter/material.dart';
import 'package:mypr/Pages/BottomNavBar.dart';

void main() => runApp(const MyPR());

class MyPR extends StatelessWidget {
  const MyPR({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'MyPR',
      debugShowCheckedModeBanner: false,
      home: BottomNavBar(),
    );
  }
}
