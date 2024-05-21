// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:flutter/material.dart' as _i15;
import 'package:mypr/MainPages/HomePage/home_page.dart' as _i6;
import 'package:mypr/MainPages/HomePage/ReservationPage/reservation_page.dart'
    as _i11;
import 'package:mypr/MainPages/ProfilePage/profile_page.dart' as _i10;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/contact_us_page.dart'
    as _i2;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/customise_profile_page.dart'
    as _i3;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/favourites_page.dart'
    as _i4;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/my_reservations_page.dart'
    as _i8;
import 'package:mypr/MainPages/SearchPage/search_page.dart' as _i12;
import 'package:mypr/Navigation/bottom_nav_bar.dart' as _i1;
import 'package:mypr/Navigation/home_navigation.dart' as _i5;
import 'package:mypr/Navigation/profile_navigation.dart' as _i9;
import 'package:mypr/OtherPages/login_page.dart' as _i7;
import 'package:mypr/OtherPages/sign_up_page.dart' as _i13;

abstract class $AppRouter extends _i14.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i14.PageFactory> pagesMap = {
    BottomNavBar.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.BottomNavBar(),
      );
    },
    ContactUsRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.ContactUsPage(),
      );
    },
    CustomiseProfileRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CustomiseProfilePage(),
      );
    },
    FavouritesRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.FavouritesPage(),
      );
    },
    HomeNavigation.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.HomeNavigation(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.HomePage(),
      );
    },
    LoginRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.LoginPage(),
      );
    },
    MyReservationsRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.MyReservationsPage(),
      );
    },
    ProfileNavigation.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.ProfileNavigation(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.ProfilePage(),
      );
    },
    ReservationRoute.name: (routeData) {
      final args = routeData.argsAs<ReservationRouteArgs>();
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i11.ReservationPage(
          key: args.key,
          clubName: args.clubName,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i12.SearchPage(),
      );
    },
    SignUpRoute.name: (routeData) {
      return _i14.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SignUpPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.BottomNavBar]
class BottomNavBar extends _i14.PageRouteInfo<void> {
  const BottomNavBar({List<_i14.PageRouteInfo>? children})
      : super(
          BottomNavBar.name,
          initialChildren: children,
        );

  static const String name = 'BottomNavBar';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i2.ContactUsPage]
class ContactUsRoute extends _i14.PageRouteInfo<void> {
  const ContactUsRoute({List<_i14.PageRouteInfo>? children})
      : super(
          ContactUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactUsRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CustomiseProfilePage]
class CustomiseProfileRoute extends _i14.PageRouteInfo<void> {
  const CustomiseProfileRoute({List<_i14.PageRouteInfo>? children})
      : super(
          CustomiseProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomiseProfileRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i4.FavouritesPage]
class FavouritesRoute extends _i14.PageRouteInfo<void> {
  const FavouritesRoute({List<_i14.PageRouteInfo>? children})
      : super(
          FavouritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavouritesRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i5.HomeNavigation]
class HomeNavigation extends _i14.PageRouteInfo<void> {
  const HomeNavigation({List<_i14.PageRouteInfo>? children})
      : super(
          HomeNavigation.name,
          initialChildren: children,
        );

  static const String name = 'HomeNavigation';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i6.HomePage]
class HomeRoute extends _i14.PageRouteInfo<void> {
  const HomeRoute({List<_i14.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i7.LoginPage]
class LoginRoute extends _i14.PageRouteInfo<void> {
  const LoginRoute({List<_i14.PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i8.MyReservationsPage]
class MyReservationsRoute extends _i14.PageRouteInfo<void> {
  const MyReservationsRoute({List<_i14.PageRouteInfo>? children})
      : super(
          MyReservationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyReservationsRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i9.ProfileNavigation]
class ProfileNavigation extends _i14.PageRouteInfo<void> {
  const ProfileNavigation({List<_i14.PageRouteInfo>? children})
      : super(
          ProfileNavigation.name,
          initialChildren: children,
        );

  static const String name = 'ProfileNavigation';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i10.ProfilePage]
class ProfileRoute extends _i14.PageRouteInfo<void> {
  const ProfileRoute({List<_i14.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i11.ReservationPage]
class ReservationRoute extends _i14.PageRouteInfo<ReservationRouteArgs> {
  ReservationRoute({
    _i15.Key? key,
    required String clubName,
    List<_i14.PageRouteInfo>? children,
  }) : super(
          ReservationRoute.name,
          args: ReservationRouteArgs(
            key: key,
            clubName: clubName,
          ),
          initialChildren: children,
        );

  static const String name = 'ReservationRoute';

  static const _i14.PageInfo<ReservationRouteArgs> page =
      _i14.PageInfo<ReservationRouteArgs>(name);
}

class ReservationRouteArgs {
  const ReservationRouteArgs({
    this.key,
    required this.clubName,
  });

  final _i15.Key? key;

  final String clubName;

  @override
  String toString() {
    return 'ReservationRouteArgs{key: $key, clubName: $clubName}';
  }
}

/// generated route for
/// [_i12.SearchPage]
class SearchRoute extends _i14.PageRouteInfo<void> {
  const SearchRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}

/// generated route for
/// [_i13.SignUpPage]
class SignUpRoute extends _i14.PageRouteInfo<void> {
  const SignUpRoute({List<_i14.PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const _i14.PageInfo<void> page = _i14.PageInfo<void>(name);
}
