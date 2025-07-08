import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mypr/Globals/classes.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Globals/global_components.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final List<BookingInfoStruct> _bookings = [];
  bool _isLoading = false;

  List<BookingInfoStruct> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Fetch bookings from server or preferences if already loaded
  Future<void> fetchBookings(
      User userDetails, ClubProvider clubProvider) async {
    setLoading(true);

    try {
      final bookingsData = await getBookings();
      if (bookingsData != null && bookingsData.isNotEmpty) {
        await _processFetchedBookings(bookingsData, userDetails, clubProvider);
        successPrint('Bookings loaded and processed successfully');
      } else {
        errorPrint('No bookings from server. Loading from preferences...');
        await _loadBookingsFromPreferences();
      }
    } catch (e) {
      errorPrint('Error fetching bookings: $e');
      await _loadBookingsFromPreferences();
    } finally {
      setLoading(false);
    }
  }

// Process fetched bookings and update UI
  Future<void> _processFetchedBookings(List<dynamic> bookingsData,
      User? userDetails, ClubProvider clubProvider) async {
    _bookings.clear();
    for (var bookingData in bookingsData) {
      bool clubFound = false;
      int clubID = bookingData['club'];
      for (int i = 0; i < clubProvider.allClubs.length; i++) {
        if (clubProvider.allClubs[i].clubID == clubID) {
          clubFound = true;
          break;
        }
      }
      if (clubFound == false) {
        return;
      }
      List<CatalogueInfoStruct> catalogues =
          clubProvider.getAllCataloguesForClubWithID(bookingData['club']);
      final regularCatalogue =
          _getCatalogue(catalogues, 0, bookingData['club'], 'Regular');
      final specialCatalogue =
          _getCatalogue(catalogues, 1, bookingData['club'], 'Special');
      final premiumCatalogue =
          _getCatalogue(catalogues, 2, bookingData['club'], 'Premium');

      _bookings.add(BookingInfoStruct(
        bookingID: bookingData['id'],
        userID: bookingData['user'],
        clubID: clubID,
        bookingName: bookingData['reservation_name'], // Use server booking name
        date: DateTime.parse(bookingData['booked_at']),
        persons: bookingData['number_of_people'],
        fourbitString: bookingData['booking_type'],
        price: _calculatePrice(
          bookingData['booking_type'],
          regularCatalogue,
          specialCatalogue,
          premiumCatalogue,
        ),
        status: _determineStatus(
          bookingData['status'],
          bookingData['booked_at'],
        ),
        comments: bookingData['comments'],
      ));
    }

    await _saveBookingsToPreferences(_bookings);

    notifyListeners(); // Notify listeners to update UI
  }

  // Helper function to get catalogues or return a default one
  CatalogueInfoStruct _getCatalogue(List<CatalogueInfoStruct> catalogues,
      int index, int clubID, String type) {
    return catalogues.length > index
        ? catalogues[index]
        : _defaultCatalogue(clubID, type);
  }

  CatalogueInfoStruct _defaultCatalogue(int clubID, String serviceType) {
    return CatalogueInfoStruct(
      clubID: clubID,
      serviceType: serviceType,
      price: '0.0',
      maxPersons: 0,
    );
  }

  // Determine booking status based on date and server status
  int _determineStatus(String status, String bookedAt) {
    final DateTime bookingDate = DateTime.parse(bookedAt);

    if (bookingDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().subtract(const Duration(days: 1)).day, 5, 0))) {
      if (status == 'Pending') {
        return 3;
      } else {
        return 2; // History (Ιστορικό)
      }
    } else if (status == 'Pending') {
      return 1; // Pending (Εκκρεμείς)
    } else if (status == 'Done') {
      return 0; // Active (Ενεργείς)
    } else {
      errorPrint('Error: Status is $status');
      return 3; // Undefined or error status
    }
  }

  // Save bookings to shared preferences
  Future<void> _saveBookingsToPreferences(
      List<BookingInfoStruct> bookings) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String bookingsJson =
          jsonEncode(bookings.map((booking) => booking.toJson()).toList());
      await prefs.setString('bookings', bookingsJson);
      successPrint('Saved bookings to preferences');
    } catch (e) {
      errorPrint('Error saving bookings to preferences: $e');
    }
  }

  // Load bookings from shared preferences
  Future<void> _loadBookingsFromPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? bookingsJson = prefs.getString('bookings');

      if (bookingsJson != null) {
        final List<dynamic> bookingsList = jsonDecode(bookingsJson);

        _bookings.clear();
        _bookings.addAll(
          bookingsList.map<BookingInfoStruct>((bookingData) {
            return BookingInfoStruct.fromJson(bookingData);
          }).toList(),
        );

        successPrint('Bookings successfully loaded from preferences');

        notifyListeners(); // Notify listeners to update UI
      } else {
        errorPrint('No bookings found in shared preferences.');
      }
    } catch (e) {
      errorPrint('Error loading bookings from preferences: $e');
    }
  }

  // Calculate price based on the fourbitString and catalogues
  double _calculatePrice(
    String fourbitString,
    CatalogueInfoStruct regularCatalogue,
    CatalogueInfoStruct specialCatalogue,
    CatalogueInfoStruct premiumCatalogue,
  ) {
    double regularBottles = double.parse(fourbitString[0]);
    double specialBottles = double.parse(fourbitString[1]);
    double premiumBottles = double.parse(fourbitString[2]);
    double regularPrice = double.parse(regularCatalogue.price);
    double specialPrice = double.parse(specialCatalogue.price);
    double premiumPrice = double.parse(premiumCatalogue.price);
    double discount = double.parse(fourbitString[3]);

    double price = (regularBottles * regularPrice) +
        (specialBottles * specialPrice) +
        (premiumBottles * premiumPrice);

    if (discount > 0) {
      if (regularBottles >= 1) {
        price -= (regularPrice * discount) / 10;
      } else if (specialBottles >= 1) {
        price -= (specialPrice * discount) / 10;
      } else if (premiumBottles >= 1) {
        price -= (premiumPrice * discount) / 10;
      }
    }

    return price;
  }

  BookingInfoStruct getBookingByBookingID(int bookingID) {
    return bookings.firstWhere((booking) => booking.bookingID == bookingID);
  }

  // Helper method to toggle loading state
  void setLoading(bool value) {
    _isLoading = value;

    notifyListeners(); // Notify listeners to update UI
  }
}
