import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global_components.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final List<BookingInfoStruct> _bookings = [];
  bool _isLoading = false;

  List<BookingInfoStruct> get bookings => _bookings;
  bool get isLoading => _isLoading;

  // Fetch bookings from server or preferences if already loaded
  Future<void> fetchBookings(
      UserInfoStruct? userDetails, ClubProvider clubProvider) async {
    print('Fetching bookings');

    setLoading(true);

    try {
      final bookingsData = await BookingService().getBookings();
      if (bookingsData != null && bookingsData.isNotEmpty) {
        print('Processing fetched bookings...');
        await _processFetchedBookings(bookingsData, userDetails, clubProvider);
        print('Bookings loaded and processed successfully');
      } else {
        print('No bookings from server. Loading from preferences...');
        await _loadBookingsFromPreferences();
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      await _loadBookingsFromPreferences();
    } finally {
      setLoading(false);
    }
  }

// Process fetched bookings and update UI
  Future<void> _processFetchedBookings(List<dynamic> bookingsData,
      UserInfoStruct? userDetails, ClubProvider clubProvider) async {
    _bookings.clear();
    for (var bookingData in bookingsData) {
      List<CatalogueInfoStruct> catalogues =
          clubProvider.getAllCatalogues(bookingData['club']);
      final regularCatalogue =
          _getCatalogue(catalogues, 0, bookingData['club'], 'Regular');
      final specialCatalogue =
          _getCatalogue(catalogues, 1, bookingData['club'], 'Special');
      final premiumCatalogue =
          _getCatalogue(catalogues, 2, bookingData['club'], 'Premium');

      _bookings.add(BookingInfoStruct(
        bookingID: bookingData['id'],
        userID: bookingData['user'],
        clubID: bookingData['club'],
        bookingName:
            userDetails?.username ?? 'Unknown User', // Use server booking name
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
        comments: _generateRandomComment(),
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

    if (bookingDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 2; // History (Ιστορικό)
    } else if (status == 'Pending') {
      return 1; // Pending (Εκκρεμείς)
    } else if (status == 'Done') {
      return 0; // Active (Ενεργείς)
    } else {
      print('Error: Status is $status');
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
      print('Saved bookings to preferences');
    } catch (e) {
      print('Error saving bookings to preferences: $e');
    }
  }

  // Load bookings from shared preferences
  Future<void> _loadBookingsFromPreferences() async {
    print('Attempting to load bookings from shared preferences...');
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

        print('Bookings successfully loaded from preferences.');
        notifyListeners(); // Notify listeners to update UI
      } else {
        print('No bookings found in shared preferences.');
      }
    } catch (e) {
      print('Error loading bookings from preferences: $e');
    }
  }

  // Calculate price based on the fourbitString and catalogues
  double _calculatePrice(
    String fourbitString,
    CatalogueInfoStruct regularCatalogue,
    CatalogueInfoStruct specialCatalogue,
    CatalogueInfoStruct premiumCatalogue,
  ) {
    double price = (double.parse(fourbitString[0]) *
            double.parse(regularCatalogue.price)) +
        (double.parse(fourbitString[1]) *
            double.parse(specialCatalogue.price)) +
        (double.parse(fourbitString[2]) * double.parse(premiumCatalogue.price));
    return price * (1 - (double.parse(fourbitString[3]) / 10));
  }

  // Generate a random comment for a booking
  String _generateRandomComment() {
    const comments = [
      'Great service!',
      'Looking forward to it!',
      'Please confirm my booking soon.',
      'Amazing experience!',
      'Not as expected.',
      'Fantastic night!',
      'Excited for the event!',
      'Looking forward to confirmation.',
      'Please make sure we have a good table.',
    ];
    return comments[Random().nextInt(comments.length)];
  }

  // Helper method to toggle loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Notify listeners to update UI
  }
}
