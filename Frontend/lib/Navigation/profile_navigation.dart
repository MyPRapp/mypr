import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfileNavigation extends StatelessWidget {
  const ProfileNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoRouter(
        placeholder: (context) =>
            const Scaffold(backgroundColor: Colors.black));
  }
}
