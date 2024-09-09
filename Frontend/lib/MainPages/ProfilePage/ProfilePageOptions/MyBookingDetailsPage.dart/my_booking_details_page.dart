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
  final String title;
  final bool isHistory;

  const BookingDetailsPage({
    super.key,
    required this.booking,
    required this.title,
    this.isHistory = false,
  });

  List<int> extractThreeBits(String bitString) {
    if (bitString.length < 3) {
      throw ArgumentError("Input must be a string of 3 bits or more.");
    }

    // Convert each character in the string to an integer
    return bitString
        .substring(0, 3)
        .split('')
        .map((bit) => int.parse(bit))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final formattedDate = DateFormat('dd/MM/yyyy').format(booking.date);
    final earnedPoints = (booking.price * 0.1).toInt();

    final discountPercentage =
        (double.parse(booking.fourbitString[3])).toInt() * 10;

    // Caching club data to avoid multiple calls
    final clubProvider = context.read<ClubProvider>();
    final clubName = clubProvider.getClubNameByID(booking.clubID);
    final clubPhoto = clubProvider.getClubByID(booking.clubID).clubPhoto;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              _buildBackground(constraints, screenHeight),
              _buildContent(context, formattedDate, earnedPoints,
                  discountPercentage, clubName, clubPhoto),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9C0C04),
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

  Widget _buildBackground(BoxConstraints constraints, double screenHeight) {
    return Container(
      height: constraints.maxHeight < screenHeight
          ? screenHeight
          : constraints.maxHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      String formattedDate,
      int earnedPoints,
      int discountPercentage,
      String clubName,
      String clubPhoto) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clubName,
                style: const TextStyle(
                  color: Color(0xFF9C0C04),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildClubPhoto(booking.clubID, context.read<ClubProvider>()),
              const SizedBox(height: 20),
              _buildBookingDetails(formattedDate),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPriceDetails(earnedPoints, discountPercentage),
              const SizedBox(height: 20),
              if (isHistory)
                _buildHistoryBottomSection(context, clubName)
              else
                _buildRegularBottomSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ],
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

  Widget _buildBookingDetails(String formattedDate) {
    List<int> fourbitIntegers = extractThreeBits(booking.fourbitString);
    final simple = fourbitIntegers[0];
    final special = fourbitIntegers[1];
    final premium = fourbitIntegers[2];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildRichText(label: 'Όνομα Κράτησης:', value: booking.bookingName),
        const SizedBox(height: 10),
        BuildRichText(label: 'Ημερομηνία:', value: formattedDate),
        const SizedBox(height: 10),
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
                      if (special > 0 &&
                          simple <=
                              0) // If no simple bottles and special is first
                        Text(
                          '$special Special',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      if (premium > 0 &&
                          simple <= 0 &&
                          special <= 0) // If premium is the first item
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
                    if (special > 0 &&
                        (simple > 0)) // Special appears under simple
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
                    if (premium > 0 &&
                        (simple > 0 ||
                            special > 0)) // Premium appears under others
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
        const SizedBox(height: 5),
        BuildRichText(label: 'Άτομα:', value: booking.persons.toString()),
        if (booking.status != 2) ...[
          const SizedBox(height: 10),
          BuildRichText(label: 'Σχόλια:', value: booking.comments),
        ],
        if (booking.status != 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text 'Συνολική Τιμή'
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

              // Column to handle both the strike-through price and actual price
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (booking.fourbitString[3] != '0')
                      // Strikethrough price
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

                    // Actual price (displayed in both cases)
                    Text('${booking.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        )),
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
