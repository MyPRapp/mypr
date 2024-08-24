import 'package:auto_route/auto_route.dart';
import 'package:mypr/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: SignUpRoute.page),
        AutoRoute(
          page: BottomNavBarRoute.page,
          children: [
            AutoRoute(
              page: HomeNavigation.page,
              initial: true,
              children: [
                AutoRoute(page: HomeRoute.page, initial: true),
                AutoRoute(page: ReservationRoute.page),
                AutoRoute(page: SearchRoute.page),
              ],
            ),
            AutoRoute(page: SearchRoute.page),
            AutoRoute(
              page: ProfileNavigation.page,
              initial: false,
              children: [
                AutoRoute(page: ProfileRoute.page),
                AutoRoute(page: CustomizeProfileRoute.page),
                AutoRoute(page: MyBookingsRoute.page, initial: false),
                AutoRoute(
                    page: BookingDetailsRoute
                        .page), // Handle booking details here
                AutoRoute(page: FavoritesRoute.page),
                AutoRoute(page: ContactUsRoute.page),
                AutoRoute(page: ReservationRoute.page),
                AutoRoute(page: HomeRoute.page),
              ],
            ),
          ],
        ),
      ];
}
