import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/club_provider.dart';
import '../../../../Widgets/booking_card_widgets.dart';
import '../../../../global_components.dart';
import '../../../../routes/app_router.gr.dart';

@RoutePage()
class BookingDetailsPage extends StatelessWidget {
  final BookingInfoStruct booking;

  const BookingDetailsPage({
    super.key,
    required this.booking,
  });

  List<int> extractThreeBits(String bitString) {
    if (bitString.length < 3) {
      throw ArgumentError("Input must be a string of 3 bits or more.");
    }
    return bitString
        .substring(0, 3)
        .split('')
        .map((bit) => int.parse(bit))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final formattedDate = DateFormat('dd/MM/yyyy').format(booking.date);
    final earnedPoints = (booking.price * 0.1).toInt();

    final discountPercentage =
        (double.parse(booking.fourbitString[3])).toInt() * 10;

    // Caching club data to avoid multiple calls
    final clubProvider = context.read<ClubProvider>();
    final clubName = clubProvider.getClubNameByID(booking.clubID);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% padding on the sides
              vertical: screenHeight * 0.03, // 3% padding on top/bottom
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
                        fontSize: screenHeight * 0.035, // 3.5% of screen height
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02), // 2% height
                    _buildClubPhoto(
                        booking.clubID, context.read<ClubProvider>()),
                    SizedBox(height: screenHeight * 0.03), // 3% height
                    _buildBookingDetails(formattedDate, screenHeight),
                  ],
                ),
                SizedBox(height: screenHeight * 0.14), // 14% height
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceDetails(earnedPoints, discountPercentage),
                    SizedBox(height: screenHeight * 0.03), // 3% height
                    if (booking.status == 2)
                      _buildHistoryBottomSection(context, clubName)
                    else
                      _buildRegularBottomSection(context),
                    SizedBox(height: screenHeight * 0.05), // 5% height
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'ΠΛΗΡΟΦΟΡΙΕΣ ΚΡΑΤΗΣΗΣ',
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
    );
  }

  Widget _buildClubPhoto(int clubID, ClubProvider clubProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: FutureBuilder<Uint8List?>(
        future: clubProvider.loadClubPhotoFromFile(clubID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            } else {
              return const Image(
                image: AssetImage('assets/images/default_club_image.png'),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              );
            }
          } else {
            return const SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF9C0C04),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBookingDetails(String formattedDate, double screenHeight) {
    List<int> fourbitIntegers = extractThreeBits(booking.fourbitString);
    final simple = fourbitIntegers[0];
    final special = fourbitIntegers[1];
    final premium = fourbitIntegers[2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildRichText(label: 'Όνομα Κράτησης:', value: booking.bookingName),
        SizedBox(height: screenHeight * 0.015), // 1.5% of screen height
        BuildRichText(label: 'Ημερομηνία:', value: formattedDate),
        SizedBox(height: screenHeight * 0.015),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Φιάλες: ',
              style: TextStyle(
                color: Color(0xFF9C0C04),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      if (simple == 1)
                        const Text(
                          '1 Απλή',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      if (simple > 1)
                        Text(
                          '$simple Απλές',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      if (special > 0 && simple <= 0)
                        Text(
                          '$special Special',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      if (premium > 0 && simple <= 0 && special <= 0)
                        Text(
                          '$premium Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (special > 0 && simple > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '$special Special',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    if (premium > 0 && (simple > 0 || special > 0))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          '$premium Premium',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        BuildRichText(label: 'Άτομα:', value: booking.persons.toString()),
        if (booking.status != 2 && booking.comments.isNotEmpty) ...[
          SizedBox(height: screenHeight * 0.015),
          BuildRichText(label: 'Σχόλια:', value: booking.comments),
        ],
        if (booking.status != 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Συνολική Τιμή: ',
                  style: TextStyle(
                    color: Color(0xFF9C0C04),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.fourbitString[3] != '0')
                      Text(
                        '${((booking.price) / (1 - (double.parse(booking.fourbitString[3]) / 10))).toStringAsFixed(2)} €',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          color: Color(0xFF9C0C04),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    Text(
                      '${booking.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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

  Widget _buildPriceDetails(int earnedPoints, int discountPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Από την κράτηση σου κέρδισες $earnedPoints πόντους.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        if (discountPercentage > 0) ...[
          const SizedBox(height: 10),
          Text(
            'Χρησιμοποιήθηκε κουπόνι $discountPercentage%.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
        const Text(
          'Για οποιαδήποτε αλλαγή ή απορία σχετικά με την κράτηση, παρακαλώ επικοινώνησε μαζί μας.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF9C0C04),
          ),
          onPressed: () {
            AutoRouter.of(context).push(const ContactUsRoute());
          },
          child: const Text(
            'Επικοινώνησε μαζί μας',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHistoryBottomSection(BuildContext context, String clubName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Για οποιαδήποτε απορία σχετικά με την κράτηση, παρακαλώ επικοινώνησε μαζί μας.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF9C0C04),
          ),
          onPressed: () {
            AutoRouter.of(context).push(const ContactUsRoute());
          },
          child: const Text(
            'Επικοινώνησε μαζί μας',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 50),
        const Text(
          'Άφησε μία κριτική:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        InteractiveNameAndStars(
          clubName: clubName,
          initialStars: 0, // Replace with actual value if available
        ),
      ],
    );
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
            style: const TextStyle(
              color: Color(0xFF9C0C04),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
