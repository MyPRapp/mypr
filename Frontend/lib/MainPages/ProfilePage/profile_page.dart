import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
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
      userProvider.fetchUserDetailsFromServer();
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final userDetails = context.watch<UserProvider>().userDetails;

    return PopScope(
      canPop: false,
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: Colors.black,
          body: userDetails == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: const Color.fromARGB(197, 40, 40, 40),
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
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 25),
                        child: Divider(
                          height: 60,
                          color: Color.fromARGB(255, 65, 65, 65),
                          thickness: 10,
                        ),
                      ),
                      Column(
                        children: [
                          profileOptions(
                            'Επεξεργασία Προφίλ',
                            const ImageIcon(
                                AssetImage("assets/icons/settings_icon.png"),
                                color: Colors.grey),
                            const CustomizeProfileRoute(),
                          ),
                          profileOptions(
                            'Οι κρατήσεις μου',
                            const ImageIcon(
                              AssetImage("assets/icons/book_icon.png"),
                              color: Colors.grey,
                            ),
                            const MyBookingsRoute(),
                          ),
                          profileOptions(
                            'Αγαπημένα',
                            const ImageIcon(
                              AssetImage("assets/icons/heart(liked)_icon.png"),
                              color: Colors.grey,
                            ),
                            const FavoritesRoute(),
                          ),
                          profileOptions(
                            'Επικοινώνησε μαζί μας',
                            const ImageIcon(
                              AssetImage("assets/icons/support_icon.png"),
                              color: Colors.grey,
                            ),
                            const ContactUsRoute(),
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
        color: Colors.grey,
        child: const Icon(
          Icons.person,
          color: Colors.black,
          size: 100,
        ),
      );
    } else {
//TODO loadUserPhoto used here

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
                color: Colors.grey,
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

  Widget profileOptions(
      String label, ImageIcon widgetIcon, PageRouteInfo route) {
    return GestureDetector(
      onTap: () {
        AutoRouter.of(context).push(route);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(left: 50, right: 50),
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
          child: Row(children: [
            SizedBox(height: 40, child: widgetIcon),
            Text(' $label',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold))
          ]),
        ),
      ),
    );
  }
}
