import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../Globals/constants.dart';
import '../../../Globals/structs.dart';
import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/booking_provider.dart';
import '../../../Providers/club_provider.dart';
import '../../../Providers/user_provider.dart';
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
      context.read<BookingProvider>().fetchBookings(
          context.read<UserProvider>().userDetails,
          context.read<ClubProvider>());
      print('aaaa');
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
        backgroundColor: const Color.fromARGB(255, 17, 17, 17),
        appBar: _buildAppBar(context),
        body: Container(
          padding: EdgeInsets.only(top: 20.h),
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
              color: appRedColor,
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
            return Center(
              child: Text(
                'Δεν βρέθηκε καμία ενεργή κράτηση.',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            );
          }
          if (status == 1) {
            return Center(
              child: Text(
                'Δεν βρέθηκε καμία εκκρεμής κράτηση.',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            );
          }
          if (status == 2) {
            return Center(
              child: Text(
                'Δεν βρέθηκε καμία κράτηση στο ιστορικό.',
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            );
          }
        }

        // Build the list of sorted bookings
        return ListView.builder(
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            return BookingCard(booking: booking);
          },
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 60.h,
      leadingWidth: 50.w,
      iconTheme: IconThemeData(
        color: Colors.white,
        size: 30.sp,
      ),
      titleTextStyle: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.sp),
      centerTitle: false,
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      title: const Text(
        'ΟΙ ΚΡΑΤΗΣΕΙΣ ΜΟΥ',
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        indicatorColor: appRedColor,
        tabs: [
          Tab(
              height: 30.h,
              child: Text('Ενεργείς', style: TextStyle(fontSize: 15.sp))),
          Tab(
              height: 30.h,
              child: Text('Εκκρεμείς', style: TextStyle(fontSize: 15.sp))),
          Tab(
              height: 30.h,
              child: Text('Ιστορικό', style: TextStyle(fontSize: 15.sp))),
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
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.h),
        child: Card(
          color: Colors.black,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide(
                color: const Color.fromARGB(255, 42, 42, 42), width: 2.sp),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.sp),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox(
                      width: 100.w,
                      height: 130.h,
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
                                  color: appRedColor,
                                  backgroundColor: Colors.black,
                                  strokeWidth: 2,
                                ))),
                ),
                SizedBox(
                  width: 20.sp,
                ),
                SizedBox(
                  height: 130.h,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        clubProvider.getClubNameByID(booking.clubID),
                        style: TextStyle(
                          color: appRedColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        booking.bookingName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      if (booking.persons > 1)
                        Text(
                          '$formattedDate - ${booking.persons} άτομα',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                          ),
                        ),
                      if (booking.persons == 1)
                        Text(
                          '$formattedDate - 1 άτομο',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                          ),
                        ),
                      SizedBox(height: 5.h),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (simple == 1)
                              Text(
                                '$simple Απλή',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ),
                            if (simple > 1)
                              Text(
                                '$simple Απλές',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ),
                            if (simple > 0 && (special > 0 || premium > 0))
                              Text(
                                ' | ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500),
                              ),
                            if (special > 0)
                              Text(
                                '$special Special',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ),
                            if (special > 0 && premium > 0)
                              Text(
                                ' | ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500),
                              ),
                            if (premium != 0)
                              Text(
                                '$premium Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                ),
                              ),
                          ]),
                      SizedBox(height: 5.h),
                      if (booking.status < 2)
                        Text(
                          '${(booking.price).toStringAsFixed(2)} €',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
