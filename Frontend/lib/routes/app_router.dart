import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.gr.dart';

@AutoRouterConfig() // Use the AutoRouterConfig annotation
class AppRouter extends RootStackRouter {
  // RootStackRouter provides router configuration
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: false),
        AutoRoute(page: SignUpRoute.page, initial: false),
        AutoRoute(
          page: BottomNavBarRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: HomeNavigation.page,
              initial: true,
              children: [
                AutoRoute(page: HomeRoute.page, initial: true),
                createSlideFromBottomRoute(ReservationRoute.page, false),
              ],
            ),
            AutoRoute(page: SearchNavigation.page, children: [
              AutoRoute(page: SearchRoute.page, initial: true),
              createSlideFromBottomRoute(ReservationRoute.page, false),
            ]),
            AutoRoute(
              page: ProfileNavigation.page,
              children: [
                AutoRoute(page: ProfileRoute.page, initial: true),
                createSlideFromRightRoute(CustomizeProfileRoute.page, false),
                createSlideFromRightRoute(MyBookingsRoute.page, false),
                createSlideFromRightRoute(BookingDetailsRoute.page, false),
                createSlideFromRightRoute(FavoritesRoute.page, false),
                createSlideFromRightRoute(ContactUsRoute.page, false),
                createSlideFromRightRoute(ReservationRoute.page, false),
              ],
            ),
          ],
        ),
      ];
}

CustomRoute createSlideFromBottomRoute(PageInfo page, bool initial) {
  return CustomRoute(
    page: page,
    initial: initial,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0); // From the bottom
      const end = Offset.zero; // To the original position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    durationInMilliseconds: 300,
  );
}

CustomRoute createSlideFromTopRoute(PageInfo page, bool initial) {
  return CustomRoute(
    page: page,
    initial: initial,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, -1.0); // From the top
      const end = Offset.zero; // To the original position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    durationInMilliseconds: 300,
  );
}

CustomRoute createSlideFromLeftRoute(PageInfo page, bool initial) {
  return CustomRoute(
    page: page,
    initial: initial,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // From the left
      const end = Offset.zero; // To the original position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    durationInMilliseconds: 300,
  );
}

CustomRoute createSlideFromRightRoute(PageInfo page, bool initial) {
  return CustomRoute(
    page: page,
    initial: initial,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0); // From the right
      const end = Offset.zero; // To the original position
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    durationInMilliseconds: 300,
  );
}
