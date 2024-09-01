import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Providers/club_provider.dart';
import '../Providers/user_provider.dart';
import '../global_components.dart';
import '../services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final List<BookingInfoStruct> _bookings = [];
  bool _bookingsLoaded = false; // Flag to track if bookings have been loaded

  List<BookingInfoStruct> get bookings => _bookings;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> fetchBookings(BuildContext context) async {
    if (_bookingsLoaded) return;

    _isLoading = true;
    notifyListeners();

    try {
      final bookingsData = await BookingService().getBookings();
      if (bookingsData != null) {
        _bookings.clear();
        _bookings.addAll(bookingsData.map<BookingInfoStruct>((bookingData) {
          final userDetails = context.read<UserProvider>().userDetails;

          // Initialize catalogues from ClubProvider
          final catalogues = context
              .read<ClubProvider>()
              .initializeCatalogues(bookingData['club']);

          // Ensure the catalogues list has the expected elements
          final regularCatalogue = catalogues.isNotEmpty
              ? catalogues[0]
              : _defaultCatalogue(bookingData['club'], 'Regular');
          final specialCatalogue = catalogues.length > 1
              ? catalogues[1]
              : _defaultCatalogue(bookingData['club'], 'Special');
          final premiumCatalogue = catalogues.length > 2
              ? catalogues[2]
              : _defaultCatalogue(bookingData['club'], 'Premium');

          return BookingInfoStruct(
            bookingID: bookingData['id'],
            userID: bookingData['user'],
            clubID: bookingData['club'],
            bookingName: userDetails?.username ?? 'Unknown User',
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
                bookingData['status'], bookingData['booked_at']),
            comments: _generateRandomComment(),
          );
        }).toList());

        // Save bookings to shared preferences
        await _saveBookingsToPreferences(_bookings);

        _bookingsLoaded = true; // Set the flag to true after fetching

        notifyListeners(); // Notify listeners to update UI
      } else {
        print(
            'No bookings available or failed to fetch bookings. Loading bookings from preferences');
        // Load bookings from shared preferences if no data from server
        await _loadBookingsFromPreferences();
      }
    } catch (e) {
      print('Failed to load bookings: $e');
      // Load bookings from shared preferences if there's an error
      print('Loading bookings from preferences');
      await _loadBookingsFromPreferences();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  CatalogueInfoStruct _defaultCatalogue(int clubID, String serviceType) {
    return CatalogueInfoStruct(
      clubID: clubID,
      serviceType: serviceType,
      price: '0.0',
      maxPersons: 0,
    );
  }

  int _determineStatus(String status, String bookedAt) {
    final DateTime bookingDate = DateTime.parse(bookedAt);

    if (bookingDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 2; // History (Ιστορικό)
    } else {
      if (status == 'Pending') {
        return 1; // Pending (Εκκρεμείς)
      } else if (status == 'Done') {
        return 0; // Active (Ενεργείς)
      } else {
        print('Error: Status is $status');
        return 3; // Undefined or error status, not displayed
      }
    }
  }

  // Save bookings to shared preferences
  Future<void> _saveBookingsToPreferences(
      List<BookingInfoStruct> bookings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String bookingsJson =
        jsonEncode(bookings.map((booking) => booking.toJson()).toList());
    await prefs.setString('bookings', bookingsJson);
  }

  // Load bookings from shared preferences
  Future<void> _loadBookingsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');

    if (bookingsJson != null) {
      final List<dynamic> bookingsList = jsonDecode(bookingsJson);

      _bookings.clear();
      _bookings.addAll(bookingsList.map<BookingInfoStruct>((bookingData) {
        return BookingInfoStruct.fromJson(bookingData);
      }).toList());

      _bookingsLoaded =
          true; // Set the flag to true after loading from preferences

      notifyListeners(); // Notify listeners to update UI
    } else {
      print('No bookings found in shared preferences.');
    }
  }

  // Additional helper methods for calculations and status determination
  double _calculatePrice(
    String fourbitString,
    CatalogueInfoStruct regularCatalogue,
    CatalogueInfoStruct specialCatalogue,
    CatalogueInfoStruct premiumCatalogue,
  ) {
    double price = (int.parse(fourbitString[0]) *
            double.parse(regularCatalogue.price)) +
        (int.parse(fourbitString[1]) * double.parse(specialCatalogue.price)) +
        (int.parse(fourbitString[2]) * double.parse(premiumCatalogue.price));
    return price * (1 - (int.parse(fourbitString[3]) / 100));
  }

  String _generateRandomComment() {
    // Generate a random comment
    final List<String> comments = [
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
}
