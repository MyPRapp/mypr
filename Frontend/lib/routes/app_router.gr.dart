// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;
import 'package:mypr/global_.components.dart' as _i18;
import 'package:mypr/MainPages/HomePage/home_page.dart' as _i7;
import 'package:mypr/MainPages/HomePage/ReservationPage/reservation_page.dart'
    as _i12;
import 'package:mypr/MainPages/ProfilePage/profile_page.dart' as _i11;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/contact_us_page.dart'
    as _i3;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/customize_profile_page.dart'
    as _i4;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/favorites_page.dart'
    as _i5;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/my_bookings.dart'
    as _i9;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/MyBookingDetailsPage.dart/my_booking_details_page.dart'
    as _i1;
import 'package:mypr/MainPages/SearchPage/search_page.dart' as _i14;
import 'package:mypr/Navigation/bottom_nav_bar.dart' as _i2;
import 'package:mypr/Navigation/home_navigation.dart' as _i6;
import 'package:mypr/Navigation/profile_navigation.dart' as _i10;
import 'package:mypr/Navigation/search_navigation.dart' as _i13;
import 'package:mypr/WelcomeScreens/login_page.dart' as _i8;
import 'package:mypr/WelcomeScreens/sign_up_page.dart' as _i15;

abstract class $AppRouter extends _i16.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i16.PageFactory> pagesMap = {
    BookingDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<BookingDetailsRouteArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.BookingDetailsPage(
          key: args.key,
          booking: args.booking,
          title: args.title,
          isHistory: args.isHistory,
        ),
      );
    },
    BottomNavBarRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.BottomNavBarPage(),
      );
    },
    ContactUsRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.ContactUsPage(),
      );
    },
    CustomizeProfileRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.CustomizeProfilePage(),
      );
    },
    FavoritesRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.FavoritesPage(),
      );
    },
    HomeNavigation.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.HomeNavigation(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.HomePage(),
      );
    },
    LoginRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.LoginPage(),
      );
    },
    MyBookingsRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.MyBookingsPage(),
      );
    },
    ProfileNavigation.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i10.ProfileNavigation(),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i11.ProfilePage(),
      );
    },
    ReservationRoute.name: (routeData) {
      final args = routeData.argsAs<ReservationRouteArgs>();
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.ReservationPage(
          key: args.key,
          club: args.club,
        ),
      );
    },
    SearchNavigation.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.SearchNavigation(),
      );
    },
    SearchRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.SearchPage(),
      );
    },
    SignUpRoute.name: (routeData) {
      return _i16.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.SignUpPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.BookingDetailsPage]
class BookingDetailsRoute extends _i16.PageRouteInfo<BookingDetailsRouteArgs> {
  BookingDetailsRoute({
    _i17.Key? key,
    required _i18.BookingInfoStruct booking,
    required String title,
    bool isHistory = false,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          BookingDetailsRoute.name,
          args: BookingDetailsRouteArgs(
            key: key,
            booking: booking,
            title: title,
            isHistory: isHistory,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingDetailsRoute';

  static const _i16.PageInfo<BookingDetailsRouteArgs> page =
      _i16.PageInfo<BookingDetailsRouteArgs>(name);
}

class BookingDetailsRouteArgs {
  const BookingDetailsRouteArgs({
    this.key,
    required this.booking,
    required this.title,
    this.isHistory = false,
  });

  final _i17.Key? key;

  final _i18.BookingInfoStruct booking;

  final String title;

  final bool isHistory;

  @override
  String toString() {
    return 'BookingDetailsRouteArgs{key: $key, booking: $booking, title: $title, isHistory: $isHistory}';
  }
}

/// generated route for
/// [_i2.BottomNavBarPage]
class BottomNavBarRoute extends _i16.PageRouteInfo<void> {
  const BottomNavBarRoute({List<_i16.PageRouteInfo>? children})
      : super(
          BottomNavBarRoute.name,
          initialChildren: children,
        );

  static const String name = 'BottomNavBarRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i3.ContactUsPage]
class ContactUsRoute extends _i16.PageRouteInfo<void> {
  const ContactUsRoute({List<_i16.PageRouteInfo>? children})
      : super(
          ContactUsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactUsRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i4.CustomizeProfilePage]
class CustomizeProfileRoute extends _i16.PageRouteInfo<void> {
  const CustomizeProfileRoute({List<_i16.PageRouteInfo>? children})
      : super(
          CustomizeProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'CustomizeProfileRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i5.FavoritesPage]
class FavoritesRoute extends _i16.PageRouteInfo<void> {
  const FavoritesRoute({List<_i16.PageRouteInfo>? children})
      : super(
          FavoritesRoute.name,
          initialChildren: children,
        );

  static const String name = 'FavoritesRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i6.HomeNavigation]
class HomeNavigation extends _i16.PageRouteInfo<void> {
  const HomeNavigation({List<_i16.PageRouteInfo>? children})
      : super(
          HomeNavigation.name,
          initialChildren: children,
        );

  static const String name = 'HomeNavigation';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i7.HomePage]
class HomeRoute extends _i16.PageRouteInfo<void> {
  const HomeRoute({List<_i16.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i8.LoginPage]
class LoginRoute extends _i16.PageRouteInfo<void> {
  const LoginRoute({List<_i16.PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i9.MyBookingsPage]
class MyBookingsRoute extends _i16.PageRouteInfo<void> {
  const MyBookingsRoute({List<_i16.PageRouteInfo>? children})
      : super(
          MyBookingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyBookingsRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i10.ProfileNavigation]
class ProfileNavigation extends _i16.PageRouteInfo<void> {
  const ProfileNavigation({List<_i16.PageRouteInfo>? children})
      : super(
          ProfileNavigation.name,
          initialChildren: children,
        );

  static const String name = 'ProfileNavigation';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i11.ProfilePage]
class ProfileRoute extends _i16.PageRouteInfo<void> {
  const ProfileRoute({List<_i16.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i12.ReservationPage]
class ReservationRoute extends _i16.PageRouteInfo<ReservationRouteArgs> {
  ReservationRoute({
    _i17.Key? key,
    required _i18.ClubInfoStruct club,
    List<_i16.PageRouteInfo>? children,
  }) : super(
          ReservationRoute.name,
          args: ReservationRouteArgs(
            key: key,
            club: club,
          ),
          initialChildren: children,
        );

  static const String name = 'ReservationRoute';

  static const _i16.PageInfo<ReservationRouteArgs> page =
      _i16.PageInfo<ReservationRouteArgs>(name);
}

class ReservationRouteArgs {
  const ReservationRouteArgs({
    this.key,
    required this.club,
  });

  final _i17.Key? key;

  final _i18.ClubInfoStruct club;

  @override
  String toString() {
    return 'ReservationRouteArgs{key: $key, club: $club}';
  }
}

/// generated route for
/// [_i13.SearchNavigation]
class SearchNavigation extends _i16.PageRouteInfo<void> {
  const SearchNavigation({List<_i16.PageRouteInfo>? children})
      : super(
          SearchNavigation.name,
          initialChildren: children,
        );

  static const String name = 'SearchNavigation';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i14.SearchPage]
class SearchRoute extends _i16.PageRouteInfo<void> {
  const SearchRoute({List<_i16.PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}

/// generated route for
/// [_i15.SignUpPage]
class SignUpRoute extends _i16.PageRouteInfo<void> {
  const SignUpRoute({List<_i16.PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const _i16.PageInfo<void> page = _i16.PageInfo<void>(name);
}
