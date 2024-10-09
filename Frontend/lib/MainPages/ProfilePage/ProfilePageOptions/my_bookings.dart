import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/booking_provider.dart';
import '../../../Providers/club_provider.dart';
import '../../../global_components.dart';
import '../../../routes/app_router.gr.dart';

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

    // Delay fetchBookings until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<BookingProvider>().bookings;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context),
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
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, int status) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, _) {
        if (bookingProvider.isLoading) {
          // Show a loading indicator while fetching data
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF9C0C04),
            ),
          );
        }

        // Filter the bookings based on their status
        final filteredBookings = bookingProvider.bookings.where((booking) {
          if (status == 0) {
            return booking.status == 0; // Active (Ενεργείς)
          } else if (status == 1) {
            return booking.status == 1; // Pending (Εκκρεμείς)
          } else if (status == 2) {
            return booking.status == 2 ||
                booking.status == 3; // History (Ιστορικό)
          } else {
            return false; // Exclude bookings with status 3 (Error or undefined)
          }
        }).toList();

        // Sort bookings by date in ascending order (closer to today first)
        filteredBookings.sort((a, b) => a.date.compareTo(b.date));

        // Show a message if there are no bookings
        if (filteredBookings.isEmpty) {
          if (status == 0) {
            return const Center(
              child: Text(
                'Δεν βρέθηκε καμία ενεργή κράτηση.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (status == 1) {
            return const Center(
              child: Text(
                'Δεν βρέθηκε καμία εκκρεμής κράτηση.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          if (status == 2) {
            return const Center(
              child: Text(
                'Δεν βρέθηκε καμία κράτηση στο ιστορικό.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        }

        // Build the list of sorted bookings
        return ListView.builder(
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: BookingCard(booking: booking),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      title: const Text(
        'ΟΙ ΚΡΑΤΗΣΕΙΣ ΜΟΥ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        indicatorColor: const Color(0xFF9C0C04),
        tabs: const [
          Tab(text: 'Ενεργείς'),
          Tab(text: 'Εκκρεμείς'),
          Tab(text: 'Ιστορικό'),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingInfoStruct booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM').format(booking.date);
    final clubProvider = context.read<ClubProvider>();
    int simple = double.parse(booking.fourbitString[0]).toInt();
    int special = double.parse(booking.fourbitString[1]).toInt();
    int premium = double.parse(booking.fourbitString[2]).toInt();
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(
          BookingDetailsRoute(
            booking: booking,
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
                child: SizedBox(
                    width: 120,
                    height: 120,
                    child: clubProvider
                            .getClubByID(booking.clubID)
                            .localPhotoPath
                            .isNotEmpty
                        ? Image.file(
                            File(clubProvider
                                .getClubByID(booking.clubID)
                                .localPhotoPath),
                            fit: BoxFit.fill,
                          ) // Load from local file
                        : clubProvider
                                .getClubByID(booking.clubID)
                                .clubPhoto
                                .isNotEmpty
                            ? Image.network(
                                clubProvider
                                    .getClubByID(booking.clubID)
                                    .clubPhoto,
                                fit: BoxFit.fill,
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                color: Color(0xFF9C0C04),
                                backgroundColor: Colors.black,
                                strokeWidth: 2,
                              ))),
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
                    if (booking.persons > 1)
                      Text(
                        '$formattedDate - ${booking.persons} άτομα',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    if (booking.persons == 1)
                      Text(
                        '$formattedDate - 1 άτομο',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      if (simple == 1)
                        Text(
                          '$simple Απλή',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      if (simple > 1)
                        Text(
                          '$simple Απλές',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      if (simple > 0 && (special > 0 || premium > 0))
                        const Text(
                          ' | ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      if (special > 0)
                        Text(
                          '$special Special',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      if (special > 0 && premium > 0)
                        const Text(
                          ' | ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      if (premium != 0)
                        Text(
                          '$premium Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ]),
                    const SizedBox(height: 5),
                    if (booking.status != 2)
                      Text(
                        '${(booking.price).toStringAsFixed(2)} €',
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
