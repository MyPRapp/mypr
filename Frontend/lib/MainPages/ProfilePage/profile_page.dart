import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../../Providers/booking_provider.dart'; // Import the BookingProvider
import '../../Providers/user_provider.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    if (mounted) {
      UserProvider userProvider = context.read<UserProvider>();
      if (userProvider.userDetails.userID < 0) {
        userProvider.fetchUserDetailsFromServer();
      }
    }
  }

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
    return PopScope(
      canPop: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: const Color.fromARGB(195, 40, 40, 40),
          body: userDetails.userID == -1
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: screenHeight / 15),
                    Column(
                      children: [
                        SizedBox(
                          height: screenWidth * screenHeight * 0.0004,
                          width: screenWidth * screenHeight * 0.0004,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: _buildProfileImage(
                                userDetails.photo, screenHeight, screenWidth),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      '${userDetails.firstName} ${userDetails.lastName}',
                      style: TextStyle(
                        fontSize: screenHeight * 0.02 + screenWidth * 0.01,
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Divider(
                      height: screenHeight * 0.1,
                      color: const Color.fromARGB(255, 65, 65, 65),
                      thickness: 10,
                    ),
                    Column(
                      children: [
                        profileOptions(
                            'Επεξεργασία Προφίλ',
                            ImageIcon(
                                size: screenHeight * 0.03 + screenWidth * 0.01,
                                const AssetImage(
                                    "assets/icons/settings_icon.png"),
                                color: Colors.grey),
                            const CustomizeProfileRoute(),
                            screenHeight,
                            screenWidth),
                        profileOptions(
                            'Οι κρατήσεις μου',
                            ImageIcon(
                              size: screenHeight * 0.03 + screenWidth * 0.01,
                              const AssetImage("assets/icons/book_icon.png"),
                              color: Colors.grey,
                            ),
                            const MyBookingsRoute(),
                            screenHeight,
                            screenWidth),
                        profileOptions(
                            'Αγαπημένα',
                            ImageIcon(
                              size: screenHeight * 0.03 + screenWidth * 0.01,
                              const AssetImage(
                                  "assets/icons/heart(liked)_icon.png"),
                              color: Colors.grey,
                            ),
                            const FavoritesRoute(),
                            screenHeight,
                            screenWidth),
                        profileOptions(
                            'Επικοινώνησε μαζί μας',
                            ImageIcon(
                              size: screenHeight * 0.03 + screenWidth * 0.01,
                              const AssetImage("assets/icons/support_icon.png"),
                              color: Colors.grey,
                            ),
                            const ContactUsRoute(),
                            screenHeight,
                            screenWidth),
                        SizedBox(
                          height: screenHeight / 40 * 6,
                        )
                      ],
                    ),
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
      return Container(
        color: Colors.grey,
        child: Icon(
          Icons.person,
          color: Colors.black,
          size: screenHeight * screenWidth * 0.0003,
        ),
      );
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
              return Container(
                color: Colors.grey,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                  size: screenHeight * screenWidth * 0.0003,
                ),
              );
            }
          } else {
            // Show a loading indicator while the photo is being loaded
            return const CircularProgressIndicator();
          }
        },
      );
    }
  }

  Widget profileOptions(String label, ImageIcon widgetIcon, PageRouteInfo route,
      double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.035),
      child: GestureDetector(
        onTap: () {
          AutoRouter.of(context).push(route);
        },
        child: Container(
          width: screenWidth * 0.85,
          height: screenHeight * 0.08,
          decoration: BoxDecoration(
              boxShadow: [
                // Light shadow for depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(2, 4),
                ),
              ],
              border: Border.all(
                  color: const Color.fromARGB(255, 65, 65, 65), width: 7),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(width: screenWidth * 0.01),
              widgetIcon,
              SizedBox(width: screenWidth * 0.01),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: screenWidth * screenHeight * 0.00006,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
