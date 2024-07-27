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
            AutoRoute(
              page: HomeNavigation.page,
              children: [
                AutoRoute(page: HomeRoute.page, initial: true),
                AutoRoute(page: SearchRoute.page),
                AutoRoute(page: ReservationRoute.page),
              ],
            ),
            AutoRoute(page: SearchRoute.page),
            AutoRoute(
              page: ProfileNavigation.page,
              initial: true,
              children: [
                AutoRoute(page: CustomizeProfileRoute.page, initial: true),
                AutoRoute(page: ProfileRoute.page),
                AutoRoute(page: MyReservationsRoute.page),
                AutoRoute(page: FavoritesRoute.page),
                AutoRoute(page: ContactUsRoute.page),
                AutoRoute(page: SignUpRoute.page),
              ],
            ),
          ],
        ),
      ];
}
