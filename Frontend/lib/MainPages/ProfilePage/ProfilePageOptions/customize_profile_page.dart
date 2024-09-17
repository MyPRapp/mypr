import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Providers/booking_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../global_components.dart';
import '../../../routes/app_router.gr.dart';

@RoutePage()
class CustomizeProfilePage extends StatefulWidget {
  const CustomizeProfilePage({super.key});

  @override
  State<CustomizeProfilePage> createState() => _CustomizeProfilePageState();
}

class _CustomizeProfilePageState extends State<CustomizeProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final userDetails = context.watch<UserProvider>().userDetails;

    /// Builds the profile image widget based on whether the photo path is valid.
    Widget buildProfileImage(
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

    void signOut(BuildContext context) async {
      try {
        print('Signing out...');

        // Step 1: Get SharedPreferences instance for key-value data
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Step 2: Retain specific keys and their values (excluding liked clubs)
        final String? validatedIp = prefs.getString('validatedIp');

        // Step 3: Clear all preferences
        await prefs.clear();
        print('Shared preferences cleared.');

        // Step 4: Restore the retained preferences (excluding liked clubs)
        if (validatedIp != null) {
          await prefs.setString('validatedIp', validatedIp);
          print('Retained validatedIp: $validatedIp');
        }

        // Step 5: Clear liked clubs
        if (context.mounted) {
          try {
            print('Clearing liked clubs...');
            ClubProvider clubProvider = context.read<ClubProvider>();
            await clubProvider.deleteAllLiked();
            print('Liked clubs cleared.');
          } catch (e) {
            print('Error clearing liked clubs: $e');
          }
        }

        // Step 6: Clear bookings and reset flags
        if (context.mounted) {
          try {
            print('Clearing bookings and resetting flags...');
            BookingProvider bookingProvider = context.read<BookingProvider>();
            bookingProvider.bookings.clear();
            bookingProvider.setLoading(false);
            print('Bookings cleared, flags reset.');
          } catch (e) {
            print('Error clearing bookings or resetting flags: $e');
          }
        }

        // Step 7: Set isAuthenticated to false
        if (context.mounted) {
          context.read<GlobalStateProvider>().isAuthenticated = false;
          print('User is authenticated flag set to false.');
        }

        // Step 8: Navigate to the Login page
        if (context.mounted) {
          print('Navigating to the login page...');
          AutoRouter.of(context).replaceAll([const LoginRoute()]);
          print('Navigation to login page successful.');
        }
      } catch (e) {
        print('Error during sign out: $e');
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1D2428),
        body: userDetails == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.035),
                        child: SizedBox(
                          height: screenHeight * 0.06,
                          width: screenWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size:
                                      screenHeight * 0.026 + screenWidth * 0.02,
                                ),
                              ),
                              Text(
                                'ΠΡΟΦΙΛ',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 90, 90, 90),
                                  fontSize:
                                      screenHeight * 0.026 + screenWidth * 0.02,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: const Color(0xFF14181B),
                        padding: EdgeInsets.only(
                          top: screenHeight * 0.02,
                          bottom: screenHeight * 0.05,
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: screenWidth * 0.03),
                            SizedBox(
                              height: screenWidth * screenHeight * 0.00036,
                              width: screenWidth * screenHeight * 0.00036,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(300),
                                child: buildProfileImage(userDetails.photo,
                                    screenHeight, screenWidth),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Expanded(
                              child: Padding(
                                padding:
                                    EdgeInsets.only(top: screenHeight * 0.028),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${userDetails.firstName} ${userDetails.lastName}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.008),
                                    Text(
                                      userDetails.phone,
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 90, 90, 90),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: screenHeight * 0.008),
                                    Text(
                                      userDetails.email,
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 90, 90, 90),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ρυθμίσεις λογαριασμού',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              height: screenHeight * 0.025,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF14181B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                title: const Text('Προσθήκη/Αλλαγή φωτογραφίας',
                                    style: TextStyle(color: Colors.white)),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                                onTap: () {
                                  // Handle change photo
                                },
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.018,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF14181B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                title: const Text('Αλλαγή ονόματος',
                                    style: TextStyle(color: Colors.white)),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                                onTap: () {
                                  // Handle change password
                                },
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.018,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF14181B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                title: const Text('Αλλαγή κωδικού',
                                    style: TextStyle(color: Colors.white)),
                                trailing: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                                onTap: () {
                                  // Handle change password
                                },
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.07,
                            ),
                            Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  signOut(context);
                                },
                                child: Container(
                                  height: screenHeight * 0.07,
                                  width: screenWidth / 2.5,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.black,
                                      border: Border.all(
                                          width: 2,
                                          color: const Color(0xFF9C0C04))),
                                  alignment: Alignment.center,
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    'Αποσύνδεση',
                                    style: TextStyle(
                                      fontSize:
                                          screenWidth * screenHeight * 0.00006,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9C0C04),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.07,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
