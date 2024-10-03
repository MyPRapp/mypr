import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeNavigation extends StatelessWidget {
  const HomeNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
        placeholder: (context) =>
            const Scaffold(backgroundColor: Color.fromARGB(197, 40, 40, 40)));
  }
}
