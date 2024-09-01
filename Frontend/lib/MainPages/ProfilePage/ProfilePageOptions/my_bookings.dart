import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Providers/club_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../global_.components.dart';
import '../../../services/booking_service.dart';

// Your custom bookings list
final List<BookingInfoStruct> bookings = [];

@RoutePage()
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
    // Fetch bookings when the page initializes
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final bookingsData = await BookingService().getBookings();

      if (bookingsData != null) {
        setState(() {
          bookings.clear(); // Clear existing bookings if any
          bookings.addAll(bookingsData.map<BookingInfoStruct>((bookingData) {
            final userDetails = context.read<UserProvider>().userDetails;
            return BookingInfoStruct(
              bookingID: bookingData['id'],
              userID: bookingData['user'],
              clubID: bookingData['club'],
              bookingName: userDetails!.username,
              date: DateTime.parse(bookingData['booked_at']),
              persons: bookingData['number_of_people'],
              fourbitString: bookingData['booking_type'],
              price: calculatePrice(
                bookingData['booking_type'],
                bookingData['club'],
              ), // Generating random price
              status: _determineStatus(
                  bookingData['status'], bookingData['booked_at']),
              comments: _generateRandomComment(), // Generating random comments
            );
          }).toList());

          // Save bookings to shared preferences
          _saveBookingsToPreferences(bookings);
        });
      } else {
        print('No bookings available or failed to fetch bookings.');
        // Load bookings from shared preferences if no data from server
        _loadBookingsFromPreferences();
      }
    } catch (e) {
      print('Failed to load bookings: $e');
      // Load bookings from shared preferences if there's an error
      _loadBookingsFromPreferences();
    }
  }

  Future<void> _saveBookingsToPreferences(
      List<BookingInfoStruct> bookings) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String bookingsJson =
        jsonEncode(bookings.map((booking) => booking.toJson()).toList());
    await prefs.setString('bookings', bookingsJson);
  }

  Future<void> _loadBookingsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bookingsJson = prefs.getString('bookings');

    if (bookingsJson != null) {
      final List<dynamic> bookingsList = jsonDecode(bookingsJson);

      setState(() {
        bookings.clear();
        bookings.addAll(bookingsList.map<BookingInfoStruct>((bookingData) {
          return BookingInfoStruct.fromJson(bookingData);
        }).toList());
      });
    } else {
      print('No bookings found in shared preferences.');
    }
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

  late CatalogueInfoStruct regularCatalogue;
  late CatalogueInfoStruct specialCatalogue;
  late CatalogueInfoStruct premiumCatalogue;

  void initializeCatalogues(int clubID) {
    ClubProvider clubProvider = context.read<ClubProvider>();
    final catalogues = clubProvider.getCataloguesByClubID(clubID);

    regularCatalogue = clubProvider.getCatalogue(
        catalogues, clubProvider.getClubByID(clubID), 'Regular');
    specialCatalogue = clubProvider.getCatalogue(catalogues,
        clubProvider.getClubByID(clubID), 'Single'); // Έτσι λεγεται πλεον
    if ((double.parse(specialCatalogue.price)).toInt() <=
        (double.parse(regularCatalogue.price)).toInt()) {
      specialCatalogue = clubProvider.getCatalogue(
          catalogues, clubProvider.getClubByID(clubID), 'Special');
    } // Έτσι λεγοταν παλια και μερικα club εχουν αυτη την τιμη
    premiumCatalogue = clubProvider.getCatalogue(
        catalogues, clubProvider.getClubByID(clubID), 'Premium');
  }

  double calculatePrice(String fourbitString, int clubID) {
    initializeCatalogues(clubID);
    double price = (int.parse(fourbitString[0]) *
            double.parse(regularCatalogue.price)) +
        (int.parse(fourbitString[1]) * double.parse(specialCatalogue.price)) +
        (int.parse(fourbitString[2]) * double.parse(premiumCatalogue.price));
    return price = price * (1 - (int.parse(fourbitString[3]) / 100));
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading:
            Container(), // This replaces the default back button with an empty container
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    AutoRouter.of(context).back();
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF9C0C04),
                    size: 40,
                  ),
                ),
                const Text(
                  'ΟΙ ΚΡΑΤΗΣΕΙΣ ΜΟΥ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF9C0C04),
          tabs: const [
            Tab(text: 'Ενεργείς'),
            Tab(text: 'Εκκρεμείς'),
            Tab(text: 'Ιστορικό'),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingList(context, 0), // Active bookings
            _buildBookingList(context, 1), // Pending bookings
            _buildBookingList(context, 2), // History bookings
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, int status) {
    // Filter bookings based on status
    final filteredBookings = bookings.where((booking) {
      if (status == 0) {
        return booking.status == 0; // Active (Ενεργείς)
      } else if (status == 1) {
        return booking.status == 1; // Pending (Εκκρεμείς)
      } else if (status == 2) {
        return booking.status == 2; // History (Ιστορικό)
      } else {
        return false; // Exclude bookings with status 3 (Error or undefined)
      }
    }).toList();

    return Column(
      children: [
        ListView.builder(
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: BookingCard(booking: booking),
            );
          },
        ),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingInfoStruct booking;

  const BookingCard({super.key, required this.booking});
  Future<ImageProvider> _loadClubPhoto(int clubID, String photoUrl) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Image = prefs.getString('club_image_$clubID');
      if (base64Image != null) {
        final Uint8List bytes = base64Decode(base64Image);
        return MemoryImage(bytes);
      } else {
        // Fallback to loading from the network if the image isn't in preferences
        return NetworkImage(photoUrl);
      }
    } catch (e) {
      // Fallback to a default asset image in case of an error
      return const AssetImage('assets/images/default_club_image.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM').format(booking.date);
    ClubProvider clubProvider = context.read<ClubProvider>();

    return GestureDetector(
      onTap: () {
        final isHistory = booking.status == 2 ||
            booking.date
                .isBefore(DateTime.now().subtract(const Duration(days: 1)));

        AutoRouter.of(context).push(
          BookingDetailsRoute(
            booking: booking,
            title: 'ΠΛΗΡΟΦΟΡΙΕΣ ΚΡΑΤΗΣΗΣ',
            isHistory: isHistory,
          ),
        );
      },
      child: Card(
        color: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Color(0xFF9C0C04), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FutureBuilder<ImageProvider>(
                  future: _loadClubPhoto(
                    booking.clubID,
                    clubProvider.getClubByID(booking.clubID).clubPhoto,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image(
                        image: snapshot.data!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubProvider.getClubNameByID(booking.clubID),
                      style: const TextStyle(
                        color: Color(0xFF9C0C04),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      booking.bookingName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$formattedDate - ${booking.persons} άτομα',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${booking.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
