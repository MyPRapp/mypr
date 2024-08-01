import 'package:auto_route/auto_route.dart';

import 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: EmailLoginRoute.page, initial: true),
        AutoRoute(page: PhoneLoginRoute.page),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(
          page: BottomNavBarRoute.page,
          children: [
            AutoRoute(
              page: HomeNavigation.page,
              children: [
                AutoRoute(page: ReservationRoute.page),
                AutoRoute(page: HomeRoute.page),
                AutoRoute(page: SearchRoute.page),
              ],
            ),
            AutoRoute(page: SearchRoute.page),
            AutoRoute(
              page: ProfileNavigation.page,
              children: [
                AutoRoute(page: ProfileRoute.page),
                AutoRoute(page: CustomizeProfileRoute.page),
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
