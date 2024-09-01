import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final double screenHeight = MediaQuery.of(context).size.height;
    final formattedDate = DateFormat('dd/MM/yyyy').format(booking.date);
    final earnedPoints = (booking.price * 0.1).toInt();
    final discountPercentage =
        (int.tryParse(booking.fourbitString[3]) ?? 0) * 10;
    ClubProvider clubProvider = context.read<ClubProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
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
            AutoRouter.of(context).back();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Container(
                height: constraints.maxHeight < screenHeight
                    ? screenHeight
                    : constraints.maxHeight,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/otherPhotos/Untitled_Artwork.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clubProvider.getClubNameByID(booking.clubID),
                              style: const TextStyle(
                                color: Color(0xFF9C0C04),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: FutureBuilder<ImageProvider>(
                                future: _loadClubPhoto(
                                  booking.clubID,
                                  clubProvider
                                      .getClubByID(booking.clubID)
                                      .clubPhoto,
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Image(
                                      image: snapshot.data!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            BuildRichText(
                                label: 'Όνομα Κράτησης:',
                                value: booking.bookingName),
                            const SizedBox(height: 10),
                            BuildRichText(
                                label: 'Ημερομηνία:', value: formattedDate),
                            const SizedBox(height: 10),
                            BuildRichText(
                                label: 'Άτομα:',
                                value: booking.persons.toString()),
                            const SizedBox(height: 10),
                            BuildRichText(
                                label: 'Σχόλια:', value: booking.comments),
                            const SizedBox(height: 20),
                            Text(
                              'Συνολική Τιμή: ${booking.price.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: Color(0xFF9C0C04),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
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
                            const SizedBox(height: 20),
                            if (isHistory)
                              _buildHistoryBottomSection(context)
                            else
                              _buildRegularBottomSection(context),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRegularBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Για οποιαδήποτε αλλαγή ή απορία σχετικά με την κράτηση, παρακαλώ επικοινωνήστε μαζί μας.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 15,
            ),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHistoryBottomSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Για οποιαδήποτε απορία σχετικά με την κράτηση, παρακαλώ επικοινωνήστε μαζί μας.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 50,
              vertical: 15,
            ),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 30),
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
          clubName:
              context.read<ClubProvider>().getClubNameByID(booking.clubID),
          initialStars: 0, // Replace with actual value
        ),
        const SizedBox(height: 30),
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
                color: Color(0xFF9C0C04), // Red color for label
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white, // White color for value
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
