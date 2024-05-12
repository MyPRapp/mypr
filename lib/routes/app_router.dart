import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: BottomNavBar.page,
          initial: true,
          children: [
            //HomePage
            AutoRoute(page: HomeNavigation.page, children: [
              AutoRoute(page: HomeRoute.page, initial: true),
              AutoRoute(page: SearchRoute.page),
              AutoRoute(page: ReservationRoute.page)
            ]),
            //SearchPage
            AutoRoute(page: SearchRoute.page),
            //ProfilePage
            AutoRoute(page: ProfileNavigation.page, children: [
              AutoRoute(page: ProfileRoute.page, initial: true),
              AutoRoute(page: CustomiseProfileRoute.page),
              AutoRoute(page: MyReservationsRoute.page),
              AutoRoute(page: FavouritesRoute.page),
              AutoRoute(page: ContactUsRoute.page),
            ]),
          ],
        ),
      ];
}
