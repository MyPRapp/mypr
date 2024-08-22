import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';

// Assuming the Booking class is defined as above

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool isPopInvoked) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<BottomNavBarVisibility>().show();
        });
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<BottomNavBarVisibility>().show();
                      });
                      context.router.back();
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
              Tab(text: 'Ιστορικό'),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.only(top: 20),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveBookings(context),
              _buildHistoryBookings(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBookings(BuildContext context) {
    ClubProvider clubProvider = context.read<ClubProvider>();
    final userDetails = context.read<UserProvider>().userDetails;
    // Replace with the actual logic to fetch active Bookings
    final activeBookings = [
      Booking(
        bookingID: 2,
        userID: userDetails!.userID,
        clubID: 2,
        bookingName: 'Γιώργος Τσόμης',
        date: DateTime.now(),
        persons: 4,
        fourbitString: '1193',
        price: 300.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 2,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 3,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 1,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
    ];

    return ListView.builder(
      itemCount: activeBookings.length,
      itemBuilder: (context, index) {
        final booking = activeBookings[index];
        clubProvider.getClubByID(booking.clubID);
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: BookingCard(booking: booking),
        );
      },
    );
  }

  Widget _buildHistoryBookings(BuildContext context) {
    final userDetails = context.read<UserProvider>().userDetails;
    // Replace with the actual logic to fetch past Bookings
    final historyBookings = [
      Booking(
        bookingID: 1,
        userID: userDetails!.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 2,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 3,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 1,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
      Booking(
        bookingID: 1,
        userID: userDetails.userID,
        clubID: 4,
        bookingName: 'Γιωργάκης Καγκούριος',
        date: DateTime.now(),
        persons: 7,
        fourbitString: '0012',
        price: 220.0,
      ),
    ];

    return ListView.builder(
      itemCount: historyBookings.length,
      itemBuilder: (context, index) {
        final booking = historyBookings[index];
        return BookingCard(booking: booking);
      },
    );
  }
}

class BookingCard extends StatefulWidget {
  const BookingCard({
    super.key,
    required this.booking,
  });

  final Booking booking;

  @override
  BookingCardState createState() => BookingCardState();
}

class BookingCardState extends State<BookingCard> {
  int regularBottles = 0;
  int specialBottles = 0;
  int premiumBottles = 0;
  int discount = 0;

  @override
  void initState() {
    super.initState();
    decodeFourbitString(widget.booking.fourbitString);
  }

  @override
  Widget build(BuildContext context) {
    // Format the date
    final formattedDate = DateFormat('dd/MM').format(widget.booking.date);
    ClubProvider clubProvider = context.read<ClubProvider>();

    return Card(
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
              child: Image.network(
                clubProvider.getClubByID(widget.booking.clubID).clubPhoto,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clubProvider.getClubNameByID(widget.booking.clubID),
                    style: const TextStyle(
                      color: Color(0xFF9C0C04),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.booking.bookingName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$formattedDate - ${widget.booking.persons} άτομα',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      // Display the number of bottles
                      if (regularBottles > 0)
                        Row(
                          children: [
                            if (regularBottles == 1)
                              const Text(
                                '1 Απλή',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            if (regularBottles > 1)
                              Text(
                                '$regularBottles Απλές',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            if (specialBottles > 0 || premiumBottles > 0)
                              const SizedBox(
                                height: 15,
                                child: VerticalDivider(
                                  color: Color(0xFF9C0C04),
                                  thickness: 3,
                                ),
                              ),
                          ],
                        ),
                      if (specialBottles > 0)
                        Row(
                          children: [
                            Text(
                              '$specialBottles Special',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            if (premiumBottles > 0)
                              const SizedBox(
                                height: 15,
                                child: VerticalDivider(
                                  color: Color(0xFF9C0C04),
                                  thickness: 3,
                                ),
                              ),
                          ],
                        ),
                      if (premiumBottles > 0)
                        Text(
                          '$premiumBottles Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Display the price
                  Text(
                    '${widget.booking.price.toStringAsFixed(2)} €',
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
    );
  }

  void decodeFourbitString(String fourbitString) {
    if (fourbitString.length == 4) {
      setState(() {
        regularBottles = int.tryParse(fourbitString[0]) ?? 0;
        specialBottles = int.tryParse(fourbitString[1]) ?? 0;
        premiumBottles = int.tryParse(fourbitString[2]) ?? 0;
        discount = (int.tryParse(fourbitString[3]) ?? 0) *
            10; // discount in percentage
      });
    }
  }
}
