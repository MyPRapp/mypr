import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:mypr/services/booking_service.dart';
import 'package:mypr/services/message_service.dart';
import 'package:provider/provider.dart';

import '../../../../Globals/classes.dart';
import '../../../../Globals/constants.dart';
import '../../../../Globals/global_components.dart';
import '../../../../Providers/global_state_provider.dart';

@RoutePage()
class BookingDetailsPage extends StatelessWidget {
  final BookingInfoStruct booking;

  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  List<int> extractFourBits(String bitString) {
    if (bitString.length < 4) {
      throw ArgumentError("Input must be a string of 4 bits or more.");
    }
    return bitString
        .substring(0, 4)
        .split('')
        .map((bit) => int.parse(bit))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(booking.date);
    final discountPercentage =
        (double.parse(booking.fourbitString[3])).toInt() * 10;

    // Caching club data to avoid multiple calls
    final clubProvider = context.read<ClubProvider>();
    final clubName = clubProvider.getClubNameByID(booking.clubID);
    List<CatalogueInfoStruct> catalogues = context
        .read<ClubProvider>()
        .getAllCataloguesForClubWithID(booking.clubID);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(context, 'ΠΛΗΡΟΦΟΡΙΕΣ ΚΡΑΤΗΣΗΣ'),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: ScreenUtil().screenHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 30.w,
                vertical: 20.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clubName,
                        style: TextStyle(
                          color: const Color(0xFF9C0C04),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildClubPhoto(
                          booking.clubID, context.read<ClubProvider>()),
                      SizedBox(height: 20.h),
                      _buildBookingDetails(formattedDate, catalogues),
                    ],
                  ),
                  SizedBox(height: 100.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking.status == 1) _buildAlertMessage(),
                      _buildPointsAndDiscount(booking.date, discountPercentage),
                      SizedBox(height: 30.h),
                      _buildRegularBottomSection(context),
                      SizedBox(height: 50.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClubPhoto(int clubID, ClubProvider clubProvider) {
    ClubInfoStruct club = clubProvider.getClubByID(clubID);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: SizedBox(
        height: 250.h,
        width: ScreenUtil().screenWidth,
        child: buildImage(club),
      ),
    );
  }

  Widget buildImage(ClubInfoStruct club) {
    return club.localPhotoPath.isNotEmpty
        ? Image(
            fit: BoxFit.fill,
            image: FileImage(File(club.localPhotoPath)),
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
              // If loading from the file fails, attempt to load from the network
              return loadNetworkImage(club);
            },
          )
        : loadNetworkImage(club);
  }

  Widget loadNetworkImage(ClubInfoStruct club) {
    if (club.clubPhoto.isNotEmpty) {
      return Image.network(
        club.clubPhoto,
        fit: BoxFit.fill,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          // If loading from the network fails, show the loading indicator
          return const Center(
            child: CircularProgressIndicator(
              color: appRedColor,
              backgroundColor: Colors.black,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      // If there's no image path, just show a loading indicator
      return const Center(
        child: CircularProgressIndicator(
          color: appRedColor,
          backgroundColor: Colors.black,
          strokeWidth: 2,
        ),
      );
    }
  }

  Widget _buildBookingDetails(
      String formattedDate, List<CatalogueInfoStruct> catalogues) {
    List<int> fourbitIntegers = extractFourBits(booking.fourbitString);
    final regular = fourbitIntegers[0];
    final special = fourbitIntegers[1];
    final premium = fourbitIntegers[2];
    final discount = fourbitIntegers[3];

    double priceWithDiscount = 0;
    if (discount > 0) {
      if (regular >= 1) {
        priceWithDiscount +=
            (double.parse(catalogues[0].price) * discount) / 10;
      } else if (special >= 1) {
        priceWithDiscount +=
            (double.parse(catalogues[1].price) * discount) / 10;
      } else if (premium >= 1) {
        priceWithDiscount +=
            (double.parse(catalogues[2].price) * discount) / 10;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildRichText(label: 'Όνομα Κράτησης:', value: booking.bookingName),
        SizedBox(height: 10.h),
        BuildRichText(label: 'Ημερομηνία:', value: formattedDate),
        SizedBox(height: 10.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Φιάλες: ',
              style: TextStyle(
                color: const Color.fromARGB(255, 113, 113, 113),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (regular == 1)
                      Text(
                        '1 Απλή',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    if (regular > 1)
                      Text(
                        '$regular Απλές',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    if (special > 0 && regular <= 0)
                      Text(
                        '$special Special',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    if (premium > 0 && regular <= 0 && special <= 0)
                      Text(
                        '$premium Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (special > 0 && regular > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '$special Special',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    if (premium > 0 && (regular > 0 || special > 0))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '$premium Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10.h),
        BuildRichText(label: 'Άτομα:', value: booking.persons.toString()),
        if (booking.status <= 1 && booking.comments.isNotEmpty) ...[
          SizedBox(height: 12.h),
          BuildRichText(label: 'Σχόλια:', value: booking.comments),
        ],
        if (booking.status <= 1)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Text(
                  'Συνολική Τιμή: ',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 113, 113, 113),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (discount > 0)
                      Text(
                        '${(booking.price + priceWithDiscount).toStringAsFixed(2)} €',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          color: const Color(0xFF9C0C04),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(
                      '${booking.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildAlertMessage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Text(
        'Η κατάσταση της κράτησης θα αλλάξει σε \'Ενεργής\' μόλις επιβεβαιώσουμε τα στοιχεία της.',
        style: TextStyle(
          color: const Color.fromARGB(255, 234, 89, 5),
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _buildPointsAndDiscount(DateTime bookingDate, int discountPercentage) {
    int getDayOfWeekFromDateString(String dateString) {
      if (dateString.isEmpty || dateString == "") {
        return -1;
      }
      // Parse the string to a DateTime object
      DateTime date = DateTime.parse(dateString);

      // Get the weekday (1 = Monday, 7 = Sunday)
      int weekday = date.weekday;

      // Return the weekday as 1 (Monday) to 7 (Sunday)
      return weekday;
    }

    int day = getDayOfWeekFromDateString(bookingDate.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day == 7 // Sunday
              ? 'Από την κράτηση σου κέρδισες 100 πόντους.'
              : day == 6 // Saturday
                  ? 'Από την κράτηση σου κέρδισες 50 πόντους.'
                  : day == 5 // Friday
                      ? 'Από την κράτηση σου κέρδισες 75 πόντους.'
                      : 'Από την κράτηση σου κέρδισες 150 πόντους.', // All the rest

          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        if (discountPercentage > 0) ...[
          SizedBox(height: 10.h),
          Text(
            'Χρησιμοποιήθηκε κουπόνι $discountPercentage%.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRegularBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          checkIfThreeDaysBefore(booking.date)
              ? 'Η ακύρωση της κράτησης θα πρέπει να γίνεται μόνο όταν είναι απολύτως απαραίτητο'
              : booking.status < 2
                  ? 'Για οποιαδήποτε αλλαγή ή απορία σχετικά με την κράτηση, παρακαλώ επικοινώνησε μαζί μας.'
                  : 'Για οποιαδήποτε απορία σχετικά με την κράτηση, παρακαλώ επικοινώνησε μαζί μας.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 20.h),
        if (checkIfThreeDaysBefore(booking.date))
          CancelReservationButton(
            booking: booking,
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF9C0C04),
            ),
            onPressed: () {
              AutoRouter.of(context).push(const ContactUsRoute());
            },
            child: Text(
              'Επικοινώνησε μαζί μας',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
          )
      ],
    );
  }

  bool checkIfThreeDaysBefore(DateTime bookingDate) {
    // Get the current date
    DateTime now = DateTime.now();

    // Strip time from both dates by creating new DateTime instances with only the date components
    DateTime bookingDateOnly =
        DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    DateTime nowDateOnly = DateTime(now.year, now.month, now.day);

    // Calculate the date that is 3 days before the booking date
    DateTime threeDaysBefore = bookingDateOnly.subtract(Duration(days: 3));

    // Check if `nowDateOnly` is equal to `threeDaysBefore`
    if (nowDateOnly.isBefore(threeDaysBefore)) {
      return true;
    } else {
      return false;
    }
  }
}

class BuildRichText extends StatelessWidget {
  final String label;
  final String value;

  const BuildRichText({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              color: const Color.fromARGB(255, 113, 113, 113),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class CancelReservationButton extends StatefulWidget {
  const CancelReservationButton({super.key, required this.booking});

  final BookingInfoStruct booking;

  @override
  State<CancelReservationButton> createState() =>
      _CancelReservationButtonState();
}

class _CancelReservationButtonState extends State<CancelReservationButton> {
  bool cancelling = false;

  void _showCancelDialog(BuildContext context) {
    showDialog(
      barrierDismissible: cancelling,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 125, 9, 3),
          titlePadding: EdgeInsets.all(20.sp),
          actionsPadding: EdgeInsets.all(20.sp),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            'Είσαι σίγουρος ότι θέλεις να ακυρώσεις την κράτηση;',
            style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Επιστροφή',
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                if (!cancelling) {
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
            ),
            TextButton(
              child: Text(
                'Ακύρωση κράτησης',
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                try {
                  if (!cancelling) {
                    setState(() {
                      cancelling = true;
                    });

                    if (await deleteBooking(widget.booking.bookingID) &&
                        context.mounted) {
                      await context.read<BookingProvider>().fetchBookings(
                          context.read<UserProvider>().userDetails,
                          context.read<ClubProvider>());

                      if (context.mounted) {
                        ClubInfoStruct club = context
                            .read<ClubProvider>()
                            .getClubByID(widget.booking.clubID);
                        await sendCancellationEmail(
                            context, club.clubName, widget.booking);
                      }

                      if (context.mounted) {
                        await context
                            .read<UserProvider>()
                            .fetchUserDetailsFromServer();
                      }
                      if (context.mounted) {
                        context.read<GlobalStateProvider>().refreshProfilePage =
                            true;
                      }
                      if (context.mounted) {
                        showFloatingSnackBar('Η κράτηση ακυρώθηκε',
                            Duration(seconds: 3), context);
                      }
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close the dialog
                        AutoRouter.of(context).back();
                      } // Close the dialog
                    } else {
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close the dialog
                        showFloatingSnackBar(
                            'Σφάλμα κατά την ακύρωση της κράτησης. Προσπάθησε ξανά σε λίγο',
                            Duration(seconds: 3),
                            context);
                      }
                    }
                    setState(() {
                      cancelling = false;
                    });
                  }
                } catch (e) {
                  errorPrint('Sonething failed: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF9C0C04),
            ),
            onPressed: () {
              _showCancelDialog(context);
            },
            child: SizedBox(
              width: 150.w,
              height: 30.h,
              child: !cancelling
                  ? Text(
                      'Ακύρωση κράτησης',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w600),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth:
                            2.0, // Optional: Adjust thickness if needed
                      ),
                    ),
            )));
  }
}
