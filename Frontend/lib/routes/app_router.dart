import 'package:auto_route/auto_route.dart';
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
                AutoRoute(page: ReservationRoute.page),
              ],
            ),
            AutoRoute(page: SearchNavigation.page, children: [
              AutoRoute(page: SearchRoute.page, initial: true),
              AutoRoute(page: ReservationRoute.page),
            ]),
            AutoRoute(
              page: ProfileNavigation.page,
              children: [
                AutoRoute(page: ProfileRoute.page, initial: true),
                AutoRoute(page: CustomizeProfileRoute.page),
                AutoRoute(page: MyBookingsRoute.page),
                AutoRoute(page: BookingDetailsRoute.page),
                AutoRoute(page: FavoritesRoute.page),
                AutoRoute(page: ContactUsRoute.page),
                AutoRoute(page: ReservationRoute.page),
              ],
            ),
          ],
        ),
      ];
}
