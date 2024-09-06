import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/profile_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

import '../../Providers/booking_provider.dart'; // Import the BookingProvider
import '../../Providers/user_provider.dart';
import '../../global_components.dart';

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
    UserProvider userProvider = context.read<UserProvider>();
    if (userProvider.userDetails!.userID < 0) {
      userProvider.syncUserDetails();
    }
  }

  Future<void> _refresh() async {
    UserProvider userProvider = context.read<UserProvider>();
    BookingProvider bookingProvider = context.read<BookingProvider>();

    await userProvider.syncUserDetails();
    if (mounted) {
      await bookingProvider.fetchBookings(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final userDetails = context.watch<UserProvider>().userDetails;

    return PopScope(
      canPop: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: userDetails == null
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                  height: screenHeight,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                        width: screenWidth,
                        child: const Image(
                          image: AssetImage('assets/otherPhotos/IMG_0041.jpg'),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment(0, -0.3),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 35),
                        child: SizedBox(
                          height: 130,
                          width: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: _buildProfileImage(userDetails.photo),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          '${userDetails.firstName} ${userDetails.lastName}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF9c0c04),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Divider(
                          height: 60,
                          color: Color.fromARGB(255, 99, 11, 4),
                          thickness: 10,
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              AutoRouter.of(context)
                                  .push(const CustomizeProfileRoute());
                            },
                            child: const ProfileOptions(
                              label: ' Επεξεργασία Προφίλ',
                              widgetIcon: ImageIcon(
                                AssetImage("assets/icons/settings_icon.png"),
                                color: Color(0xFF9c0c04),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              AutoRouter.of(context)
                                  .push(const MyBookingsRoute());
                            },
                            child: const ProfileOptions(
                              label: ' Οι κρατήσεις μου',
                              widgetIcon: ImageIcon(
                                AssetImage("assets/icons/book_icon.png"),
                                color: Color(0xFF9c0c04),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              AutoRouter.of(context)
                                  .push(const FavoritesRoute());
                            },
                            child: const ProfileOptions(
                              label: ' Αγαπημένα',
                              widgetIcon: ImageIcon(
                                AssetImage(
                                    "assets/icons/heart(liked)_icon.png"),
                                color: Color(0xFF9c0c04),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () {
                              AutoRouter.of(context)
                                  .push(const ContactUsRoute());
                            },
                            child: const ProfileOptions(
                              label: ' Επικοινώνησε μαζί μας',
                              widgetIcon: ImageIcon(
                                AssetImage("assets/icons/support_icon.png"),
                                color: Color(0xFF9c0c04),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Builds the profile image widget based on whether the photo path is valid.
  Widget _buildProfileImage(String? photoPath) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      // Show the red person icon immediately if photoPath is empty or null
      return Container(
        color: const Color(0xFF9C0C04),
        child: const Icon(
          Icons.person,
          color: Colors.black,
          size: 100,
        ),
      );
    } else {
      // Attempt to load the photo; show a loading indicator if the result is null
      return FutureBuilder<ImageProvider?>(
        future: loadUserPhoto(photoPath),
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
                color: const Color(0xFF9C0C04),
                child: const Icon(
                  Icons.person,
                  color: Colors.black,
                  size: 100,
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
}
