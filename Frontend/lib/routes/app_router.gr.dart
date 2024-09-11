// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i16;
import 'package:flutter/material.dart' as _i17;
import 'package:mypr/MainPages/HomePage/ReservationPage/reservation_page.dart'
    as _i12;
import 'package:mypr/MainPages/HomePage/home_page.dart' as _i7;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/MyBookingDetailsPage.dart/my_booking_details_page.dart'
    as _i1;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/contact_us_page.dart'
    as _i3;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/customize_profile_page.dart'
    as _i4;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/favorites_page.dart'
    as _i5;
import 'package:mypr/MainPages/ProfilePage/ProfilePageOptions/my_bookings.dart'
    as _i9;
import 'package:mypr/MainPages/ProfilePage/profile_page.dart' as _i11;
import 'package:mypr/MainPages/SearchPage/search_page.dart' as _i14;
import 'package:mypr/Navigation/bottom_nav_bar.dart' as _i2;
import 'package:mypr/Navigation/home_navigation.dart' as _i6;
import 'package:mypr/Navigation/profile_navigation.dart' as _i10;
import 'package:mypr/Navigation/search_navigation.dart' as _i13;
import 'package:mypr/WelcomeScreens/login_page.dart' as _i8;
import 'package:mypr/WelcomeScreens/sign_up_page.dart' as _i15;
import 'package:mypr/global_components.dart' as _i18;

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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BookingDetailsRouteArgs>();
      return _i1.BookingDetailsPage(
        key: args.key,
        booking: args.booking,
        title: args.title,
        isHistory: args.isHistory,
      );
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i2.BottomNavBarPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return _i3.ContactUsPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i4.CustomizeProfilePage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i5.FavoritesPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeNavigation();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i7.HomePage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i8.LoginPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i9.MyBookingsPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i10.ProfileNavigation();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i11.ProfilePage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ReservationRouteArgs>();
      return _i12.ReservationPage(
        key: args.key,
        club: args.club,
      );
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i13.SearchNavigation();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i14.SearchPage();
    },
  );
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

  static _i16.PageInfo page = _i16.PageInfo(
    name,
    builder: (data) {
      return const _i15.SignUpPage();
    },
  );
}
