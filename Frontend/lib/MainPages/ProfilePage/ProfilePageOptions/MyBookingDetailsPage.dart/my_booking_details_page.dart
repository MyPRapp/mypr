import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/club_provider.dart';
import '../../../../Widgets/booking_card_widgets.dart';
import '../../../../global_components.dart';
import '../../../../routes/app_router.gr.dart';

//TODO Show to user number of bottles, divide page in 2 parts(column with MainAxisAlignment.spaceBetween)
//TODO fix photo's space from being empty when page loads

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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final formattedDate = DateFormat('dd/MM/yyyy').format(booking.date);
    final earnedPoints = (booking.price * 0.1).toInt();
    final discountPercentage =
        (double.tryParse(booking.fourbitString[3]) ?? 0) * 10;

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
          AutoRouter.of(context).back();
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
      double discountPercentage,
      String clubName,
      String clubPhoto) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
            _buildClubPhoto(booking.clubID, clubPhoto),
            const SizedBox(height: 20),
            _buildBookingDetails(formattedDate),
            const SizedBox(height: 20),
            _buildPriceDetails(earnedPoints, discountPercentage),
            const SizedBox(height: 20),
            if (isHistory)
              _buildHistoryBottomSection(context, clubName)
            else
              _buildRegularBottomSection(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildClubPhoto(int clubID, String clubPhoto) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: FutureBuilder<ImageProvider>(
        future: loadClubPhoto(clubID, clubPhoto),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image(
              image: snapshot.data!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            );
          } else {
            return const SizedBox(
              width: double.infinity,
              height: 200,
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF9C0C04))),
            );
          }
        },
      ),
    );
  }

  Widget _buildBookingDetails(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildRichText(label: 'Όνομα Κράτησης:', value: booking.bookingName),
        const SizedBox(height: 10),
        BuildRichText(label: 'Ημερομηνία:', value: formattedDate),
        const SizedBox(height: 10),
        BuildRichText(label: 'Άτομα:', value: booking.persons.toString()),
        const SizedBox(height: 10),
        BuildRichText(label: 'Σχόλια:', value: booking.comments),
      ],
    );
  }

  Widget _buildPriceDetails(int earnedPoints, double discountPercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (booking.status != 2)
          Text(
            'Συνολική Τιμή: ${booking.price.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Color(0xFF9C0C04),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 20),
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
          'Για οποιαδήποτε αλλαγή ή απορία σχετικά με την κράτηση, παρακαλώ επικοινωνήστε μαζί μας.',
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
          'Για οποιαδήποτε απορία σχετικά με την κράτηση, παρακαλώ επικοινωνήστε μαζί μας.',
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
