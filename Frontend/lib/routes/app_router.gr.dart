// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:flutter/material.dart' as _i16;
import 'package:mypr/MainPages/HomePage/home_page.dart' as _i7;
import 'package:mypr/MainPages/HomePage/ReservationPage/reservation_page.dart'
    as _i12;
import 'package:mypr/MainPages/ProfilePage/profile_page.dart' as _i11;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/contact_us_page.dart'
    as _i2;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/customize_profile_page.dart'
    as _i3;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/favorites_page.dart'
    as _i5;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/my_reservations_page.dart'
    as _i8;
import 'package:mypr/MainPages/SearchPage/search_page.dart' as _i13;
import 'package:mypr/Navigation/bottom_nav_bar.dart' as _i1;
import 'package:mypr/Navigation/home_navigation.dart' as _i6;
import 'package:mypr/Navigation/profile_navigation.dart' as _i10;
import 'package:mypr/OtherPages/email_login_page.dart' as _i4;
import 'package:mypr/OtherPages/phone_login_page.dart' as _i9;
import 'package:mypr/OtherPages/sign_up_page.dart' as _i14;

abstract class $AppRouter extends _i15.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i15.PageFactory> pagesMap = {
    BottomNavBarRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.BottomNavBarPage(),
      );
    },
    ContactUsRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.ContactUsPage(),
      );
    },
    CustomizeProfileRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CustomizeProfilePage(),
      );
    },
    EmailLoginRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.EmailLoginPage(),
      );
    },
    FavoritesRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.FavoritesPage(),
      );
    },
    HomeNavigation.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.HomeNavigation(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.HomePage(),
      );
    },
    MyReservationsRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.MyReservationsPage(),
      );
    },
    PhoneLoginRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.PhoneLoginPage(),
      );
    },
    ProfileNavigation.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.ProfileNavigation(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.ProfilePage(),
      );
    },
    ReservationRoute.name: (routeData) {
      final args = routeData.argsAs<ReservationRouteArgs>();
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.ReservationPage(
          key: args.key,
          clubName: args.clubName,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SearchPage(),
      );
    },
    SignUpRoute.name: (routeData) {
      return _i15.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.SignUpPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.BottomNavBarPage]
class BottomNavBarRoute extends _i15.PageRouteInfo<void> {
  const BottomNavBarRoute({List<_i15.PageRouteInfo>? children})
      : super(
          BottomNavBarRoute.name,
          initialChildren: children,
        );

  static const String name = 'BottomNavBarRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i2.ContactUsPage]
class ContactUsRoute extends _i15.PageRouteInfo<void> {
  const ContactUsRoute({List<_i15.PageRouteInfo>? children})
      : super(
          ContactUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactUsRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CustomizeProfilePage]
class CustomizeProfileRoute extends _i15.PageRouteInfo<void> {
  const CustomizeProfileRoute({List<_i15.PageRouteInfo>? children})
      : super(
          CustomizeProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomizeProfileRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i4.EmailLoginPage]
class EmailLoginRoute extends _i15.PageRouteInfo<void> {
  const EmailLoginRoute({List<_i15.PageRouteInfo>? children})
      : super(
          EmailLoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'EmailLoginRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i5.FavoritesPage]
class FavoritesRoute extends _i15.PageRouteInfo<void> {
  const FavoritesRoute({List<_i15.PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i6.HomeNavigation]
class HomeNavigation extends _i15.PageRouteInfo<void> {
  const HomeNavigation({List<_i15.PageRouteInfo>? children})
      : super(
          HomeNavigation.name,
          initialChildren: children,
        );

  static const String name = 'HomeNavigation';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i7.HomePage]
class HomeRoute extends _i15.PageRouteInfo<void> {
  const HomeRoute({List<_i15.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i8.MyReservationsPage]
class MyReservationsRoute extends _i15.PageRouteInfo<void> {
  const MyReservationsRoute({List<_i15.PageRouteInfo>? children})
      : super(
          MyReservationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyReservationsRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i9.PhoneLoginPage]
class PhoneLoginRoute extends _i15.PageRouteInfo<void> {
  const PhoneLoginRoute({List<_i15.PageRouteInfo>? children})
      : super(
          PhoneLoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'PhoneLoginRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i10.ProfileNavigation]
class ProfileNavigation extends _i15.PageRouteInfo<void> {
  const ProfileNavigation({List<_i15.PageRouteInfo>? children})
      : super(
          ProfileNavigation.name,
          initialChildren: children,
        );

  static const String name = 'ProfileNavigation';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i11.ProfilePage]
class ProfileRoute extends _i15.PageRouteInfo<void> {
  const ProfileRoute({List<_i15.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i12.ReservationPage]
class ReservationRoute extends _i15.PageRouteInfo<ReservationRouteArgs> {
  ReservationRoute({
    _i16.Key? key,
    required String clubName,
    List<_i15.PageRouteInfo>? children,
  }) : super(
          ReservationRoute.name,
          args: ReservationRouteArgs(
            key: key,
            clubName: clubName,
          ),
          initialChildren: children,
        );

  static const String name = 'ReservationRoute';

  static const _i15.PageInfo<ReservationRouteArgs> page =
      _i15.PageInfo<ReservationRouteArgs>(name);
}

class ReservationRouteArgs {
  const ReservationRouteArgs({
    this.key,
    required this.clubName,
  });

  final _i16.Key? key;

  final String clubName;

  @override
  String toString() {
    return 'ReservationRouteArgs{key: $key, clubName: $clubName}';
  }
}

/// generated route for
/// [_i13.SearchPage]
class SearchRoute extends _i15.PageRouteInfo<void> {
  const SearchRoute({List<_i15.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}

/// generated route for
/// [_i14.SignUpPage]
class SignUpRoute extends _i15.PageRouteInfo<void> {
  const SignUpRoute({List<_i15.PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const _i15.PageInfo<void> page = _i15.PageInfo<void>(name);
}
