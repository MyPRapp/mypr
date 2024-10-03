import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../../Providers/booking_provider.dart'; // Import the BookingProvider
import '../../Providers/global_state_provider.dart';
import '../../Providers/user_provider.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _refresh() async {
    UserProvider userProvider = context.read<UserProvider>();
    BookingProvider bookingProvider = context.read<BookingProvider>();

    await userProvider.fetchUserDetailsFromServer();
    if (mounted) {
      await bookingProvider.fetchBookings(
          userProvider.userDetails, context.read<ClubProvider>());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final userDetails = context.watch<UserProvider>().userDetails;
    final bool isAuthenticated =
        context.watch<GlobalStateProvider>().isAuthenticated;
    return PopScope(
      canPop: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              GlassContainer(
                border: 0,
                borderRadius: BorderRadius.circular(0),
                alignment: Alignment.center,
                width: screenWidth,
                blur: 20,
                linearGradient:
                    LinearGradient(begin: Alignment.bottomRight, colors: [
                  const Color.fromARGB(153, 48, 2, 2).withOpacity(.8),
                  const Color.fromARGB(69, 0, 0, 0).withOpacity(.1)
                ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.06),
                    SizedBox(
                      height: screenWidth * screenHeight * 0.0004,
                      width: screenWidth * screenHeight * 0.0004,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(300),
                        child: _buildProfileImage(
                            userDetails.photo, screenHeight, screenWidth),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.03),
                      child: Text(
                        '${userDetails.firstName} ${userDetails.lastName}',
                        style: TextStyle(
                          fontSize: screenHeight * 0.02 + screenWidth * 0.01,
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                child: Divider(
                  height: screenHeight * 0.01,
                  color: const Color.fromARGB(153, 48, 2, 2).withOpacity(.8),
                  thickness: 8,
                ),
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.85, // Adjust the width as needed
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: const Color.fromARGB(255, 34, 34, 34),
                  ),
                  child: Column(
                    children: [
                      if (isAuthenticated)
                        profileOptions(
                            'Επεξεργασία Προφίλ',
                            const CustomizeProfileRoute(),
                            screenHeight,
                            screenWidth),
                      if (isAuthenticated)
                        Divider(
                          color: Colors.white,
                          thickness: 0.3,
                          height: screenHeight * 0.01,
                        ),
                      if (isAuthenticated)
                        profileOptions('Οι κρατήσεις μου',
                            const MyBookingsRoute(), screenHeight, screenWidth),
                      if (isAuthenticated)
                        Divider(
                          color: Colors.white,
                          thickness: 0.3,
                          height: screenHeight * 0.01,
                        ),
                      profileOptions('Αγαπημένα', const FavoritesRoute(),
                          screenHeight, screenWidth),
                      Divider(
                        color: Colors.white,
                        thickness: 0.3,
                        height: screenHeight * 0.01,
                      ),
                      profileOptions('Επικοινώνησε μαζί μας',
                          const ContactUsRoute(), screenHeight, screenWidth),
                    ],
                  ),
                ),
              ),
              if (!isAuthenticated) SizedBox(height: screenHeight * 0.1),
              if (!isAuthenticated)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      AutoRouter.of(context).replaceAll([const SignUpRoute()]);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 10,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: const Color.fromARGB(
                          136, 173, 173, 173), // Text color
                      minimumSize: Size(screenWidth * 0.45,
                          screenHeight * 0.06), // Button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.5),
                        side: const BorderSide(
                          width: 4,
                          color: Color.fromARGB(255, 0, 0, 0), // Border color
                        ),
                      ),
                    ),
                    child: Text(
                      'Εγγραφή/Σύνδεση',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              // SizedBox(height: screenHeight * 0.035),
              // Center(
              //   child: GestureDetector(
              //     behavior: HitTestBehavior.translucent,
              //     onTap: () {
              //       signOut();
              //     },
              //     child: Container(
              //       height: screenHeight * 0.07,
              //       width: screenWidth / 2.5,
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(14),
              //           color: const Color.fromARGB(162, 15, 15, 15),
              //           border: Border.all(
              //               width: 2,
              //               color:
              //                   const Color.fromARGB(108, 156, 12, 4))),
              //       alignment: Alignment.center,
              //       child: Text(
              //         textAlign: TextAlign.center,
              //         'Αποσύνδεση',
              //         style: TextStyle(
              //           fontSize: screenWidth * screenHeight * 0.00006,
              //           fontWeight: FontWeight.w700,
              //           color: const Color.fromARGB(199, 235, 230, 230),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: screenHeight * 0.15),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the profile image widget based on whether the photo path is valid.
  Widget _buildProfileImage(
      String? photoPath, double screenHeight, double screenWidth) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      // Show the red person icon immediately if photoPath is empty or null
      return const Image(
          image: AssetImage('assets/otherPhotos/Default_User.jpg'));
    } else {
      // Attempt to load the photo; show a loading indicator if the result is null
      return FutureBuilder<ImageProvider?>(
        future: context.read<UserProvider>().loadUserPhoto(photoPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image(
                image: snapshot.data!,
                fit: BoxFit.cover,
              );
            } else {
              // If the photo couldn't be loaded, show the red person icon
              return const Image(
                  image: AssetImage('assets/otherPhotos/Default_User.jpg'));
            }
          } else {
            // Show a loading indicator while the photo is being loaded
            return const CircularProgressIndicator();
          }
        },
      );
    }
  }

  Widget profileOptions(String label, PageRouteInfo route, double screenHeight,
      double screenWidth) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        AutoRouter.of(context).push(route);
      },
      child: Padding(
        padding: EdgeInsets.only(
            left: screenWidth * 0.02,
            bottom: screenHeight * 0.02,
            top: screenHeight * 0.02),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(label,
              style: TextStyle(
                  fontSize: screenWidth * screenHeight * 0.00006,
                  color: const Color.fromARGB(255, 170, 170, 170),
                  fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }
}
