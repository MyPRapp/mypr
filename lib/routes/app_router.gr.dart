// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:flutter/material.dart' as _i13;
import 'package:mypr/Pages/bottom_nav_bar.dart' as _i1;
import 'package:mypr/Pages/HomePage/home_page.dart' as _i6;
import 'package:mypr/Pages/HomePage/ReservationPage/reservation_page.dart'
    as _i10;
import 'package:mypr/Pages/Navigation/home_navigation.dart' as _i5;
import 'package:mypr/Pages/Navigation/profile_navigation.dart' as _i8;
import 'package:mypr/Pages/ProfilePage/profile_page.dart' as _i9;
import 'package:mypr/Pages/ProfilePage/ProfilePageOptions/contact_us_page.dart'
    as _i2;
import 'package:mypr/Pages/ProfilePage/ProfilePageOptions/customise_profile_page.dart'
    as _i3;
import 'package:mypr/Pages/ProfilePage/ProfilePageOptions/favourites_page.dart'
    as _i4;
import 'package:mypr/Pages/ProfilePage/ProfilePageOptions/my_reservations_page.dart'
    as _i7;
import 'package:mypr/Pages/SearchPage/search_page.dart' as _i11;

abstract class $AppRouter extends _i12.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i12.PageFactory> pagesMap = {
    BottomNavBar.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.BottomNavBar(),
      );
    },
    ContactUsRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.ContactUsPage(),
      );
    },
    CustomiseProfileRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CustomiseProfilePage(),
      );
    },
    FavouritesRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.FavouritesPage(),
      );
    },
    HomeNavigation.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.HomeNavigation(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.HomePage(),
      );
    },
    MyReservationsRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.MyReservationsPage(),
      );
    },
    ProfileNavigation.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.ProfileNavigation(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.ProfilePage(),
      );
    },
    ReservationRoute.name: (routeData) {
      final args = routeData.argsAs<ReservationRouteArgs>();
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.ReservationPage(
          key: args.key,
          clubName: args.clubName,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return _i12.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.SearchPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.BottomNavBar]
class BottomNavBar extends _i12.PageRouteInfo<void> {
  const BottomNavBar({List<_i12.PageRouteInfo>? children})
      : super(
          BottomNavBar.name,
          initialChildren: children,
        );

  static const String name = 'BottomNavBar';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i2.ContactUsPage]
class ContactUsRoute extends _i12.PageRouteInfo<void> {
  const ContactUsRoute({List<_i12.PageRouteInfo>? children})
      : super(
          ContactUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactUsRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CustomiseProfilePage]
class CustomiseProfileRoute extends _i12.PageRouteInfo<void> {
  const CustomiseProfileRoute({List<_i12.PageRouteInfo>? children})
      : super(
          CustomiseProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomiseProfileRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i4.FavouritesPage]
class FavouritesRoute extends _i12.PageRouteInfo<void> {
  const FavouritesRoute({List<_i12.PageRouteInfo>? children})
      : super(
          FavouritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavouritesRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i5.HomeNavigation]
class HomeNavigation extends _i12.PageRouteInfo<void> {
  const HomeNavigation({List<_i12.PageRouteInfo>? children})
      : super(
          HomeNavigation.name,
          initialChildren: children,
        );

  static const String name = 'HomeNavigation';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i6.HomePage]
class HomeRoute extends _i12.PageRouteInfo<void> {
  const HomeRoute({List<_i12.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i7.MyReservationsPage]
class MyReservationsRoute extends _i12.PageRouteInfo<void> {
  const MyReservationsRoute({List<_i12.PageRouteInfo>? children})
      : super(
          MyReservationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyReservationsRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i8.ProfileNavigation]
class ProfileNavigation extends _i12.PageRouteInfo<void> {
  const ProfileNavigation({List<_i12.PageRouteInfo>? children})
      : super(
          ProfileNavigation.name,
          initialChildren: children,
        );

  static const String name = 'ProfileNavigation';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i9.ProfilePage]
class ProfileRoute extends _i12.PageRouteInfo<void> {
  const ProfileRoute({List<_i12.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}

/// generated route for
/// [_i10.ReservationPage]
class ReservationRoute extends _i12.PageRouteInfo<ReservationRouteArgs> {
  ReservationRoute({
    _i13.Key? key,
    required String clubName,
    List<_i12.PageRouteInfo>? children,
  }) : super(
          ReservationRoute.name,
          args: ReservationRouteArgs(
            key: key,
            clubName: clubName,
          ),
          initialChildren: children,
        );

  static const String name = 'ReservationRoute';

  static const _i12.PageInfo<ReservationRouteArgs> page =
      _i12.PageInfo<ReservationRouteArgs>(name);
}

class ReservationRouteArgs {
  const ReservationRouteArgs({
    this.key,
    required this.clubName,
  });

  final _i13.Key? key;

  final String clubName;

  @override
  String toString() {
    return 'ReservationRouteArgs{key: $key, clubName: $clubName}';
  }
}

/// generated route for
/// [_i11.SearchPage]
class SearchRoute extends _i12.PageRouteInfo<void> {
  const SearchRoute({List<_i12.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i12.PageInfo<void> page = _i12.PageInfo<void>(name);
}
