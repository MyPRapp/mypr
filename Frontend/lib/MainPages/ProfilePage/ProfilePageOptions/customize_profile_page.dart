import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/global_components.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Providers/booking_provider.dart';
import '../../../Providers/user_provider.dart';
import '../../../routes/app_router.gr.dart';

@RoutePage()
class CustomizeProfilePage extends StatelessWidget {
  const CustomizeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userDetails = context.watch<UserProvider>().userDetails;
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

    return Scaffold(
      backgroundColor: const Color(0xFF1D2428),
      body: userDetails == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFF14181B),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                              const Text(
                                'ΠΡΟΦΙΛ',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 90, 90, 90),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
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
                            const SizedBox(width: 16),
                            Expanded(
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
                                  const SizedBox(height: 4),
                                  Text(
                                    userDetails.phone,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 90, 90, 90),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userDetails.email,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 90, 90, 90),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                  color: Color(0xFF9C0C04), width: 2),
                            ),
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            signOut(context);
                          },
                          child: const Text(
                            'Αποσύνδεση',
                            style: TextStyle(
                              color: Color(0xFF9C0C04),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              // If the photo couldn't be loaded, show a loading indicator
              return const CircularProgressIndicator();
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
