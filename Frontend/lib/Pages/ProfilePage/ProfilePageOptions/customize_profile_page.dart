import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Globals/global_components.dart';
import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/booking_provider.dart';
import '../../../Providers/user_provider.dart';
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

    void signOut() async {
      try {
        warningPrint('------------SIGNING OUT------------');

        // Step 1: Get SharedPreferences instance for key-value data
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Step 2: Retain specific keys and their values (excluding liked clubs)
        final String? validatedIp = prefs.getString('validatedIp');
        final String? savedEmail = prefs.getString('savedEmail');
        final String? savedPassword = prefs.getString('savedPassword');

        // Step 3: Clear all preferences
        await prefs.clear();
        successPrint('Shared preferences cleared.');

        // Step 4: Restore the retained preferences (excluding liked clubs)
        if (validatedIp != null) {
          await prefs.setString('validatedIp', validatedIp);
          successPrint('Retained validatedIp: $validatedIp');
        }
        if (savedEmail != null) {
          await prefs.setString('savedEmail', savedEmail);
          successPrint('Retained savedEmail: $savedEmail');
        }
        if (savedPassword != null) {
          await prefs.setString('savedPassword', savedPassword);
          successPrint('Retained savedPassword: $savedPassword');
        }

        // Step 5: Clear liked clubs
        if (context.mounted) {
          warningPrint('Clearing liked clubs...');
          await context.read<LikedClubsProvider>().deleteAllLiked();
        }

        // Step 6: Clear bookings and reset flags
        if (context.mounted) {
          try {
            warningPrint('Clearing bookings and resetting flags...');
            BookingProvider bookingProvider = context.read<BookingProvider>();
            bookingProvider.bookings.clear();
            bookingProvider.setLoading(false);
            successPrint('Bookings cleared');
          } catch (e) {
            errorPrint('Error clearing bookings: $e');
          }
        }

        // Step 7: Set isAuthenticated to false
        if (context.mounted) {
          context.read<GlobalStateProvider>().isAuthenticated = false;
          successPrint('\'isAuthenticated\' flag set to false.');
        }
        // Step 8: Reset saved user details
        if (context.mounted) {
          context.read<UserProvider>().resetUserDetails();
          successPrint('Successfully restored user details.');
        }

        // Step 9: Navigate to the Login page
        if (context.mounted) {
          warningPrint('Navigating to the login page...');
          AutoRouter.of(context).replaceAll([const LoginRoute()]);
          successPrint('Navigation to login page successful.');
        }
        successPrint('------------SIGNED OUT------------');
      } catch (e) {
        errorPrint('Error during sign out: $e');
      }
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: userDetails.userID == -1
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ListView(
                  children: [
                    Padding(
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
                                child: context
                                        .read<GlobalStateProvider>()
                                        .isAuthenticated
                                    ? userDetails.localPhotoPath.isNotEmpty
                                        ? Image.file(
                                            File(userDetails.localPhotoPath),
                                            fit: BoxFit.cover,
                                          ) // Load from local file
                                        : userDetails.photo.isNotEmpty
                                            ? Image.network(
                                                'http://$validatedIP${userDetails.photo}',
                                                fit: BoxFit.cover,
                                              )
                                            : const Image(
                                                image: AssetImage(
                                                    'assets/otherPhotos/Default_User.jpg'))
                                    : const Image(
                                        image: AssetImage(
                                            'assets/otherPhotos/Default_User.jpg'))),
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
                                        color: Color.fromARGB(255, 90, 90, 90),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: screenHeight * 0.008),
                                  Text(
                                    userDetails.email,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 90, 90, 90),
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
                              // const Text(
                              //   'Ρυθμίσεις λογαριασμού',
                              //   style: TextStyle(
                              //       color: Colors.grey,
                              //       fontSize: 16,
                              //       fontWeight: FontWeight.w400),
                              // ),
                              // SizedBox(
                              //   height: screenHeight * 0.025,
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: const Color(0xFF14181B),
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              //   child: ListTile(
                              //     contentPadding: const EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 12),
                              //     title: const Text('Προσθήκη/Αλλαγή φωτογραφίας',
                              //         style: TextStyle(color: Colors.white)),
                              //     trailing: const Icon(Icons.chevron_right,
                              //         color: Colors.white),
                              //     onTap: () {
                              //       // Handle change photo
                              //     },
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: screenHeight * 0.018,
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: const Color(0xFF14181B),
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              //   child: ListTile(
                              //     contentPadding: const EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 12),
                              //     title: const Text('Αλλαγή ονόματος',
                              //         style: TextStyle(color: Colors.white)),
                              //     trailing: const Icon(Icons.chevron_right,
                              //         color: Colors.white),
                              //     onTap: () {
                              //       // Handle change password
                              //     },
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: screenHeight * 0.018,
                              // ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: const Color(0xFF14181B),
                              //     borderRadius: BorderRadius.circular(12),
                              //   ),
                              //   child: ListTile(
                              //     contentPadding: const EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 12),
                              //     title: const Text('Αλλαγή κωδικού',
                              //         style: TextStyle(color: Colors.white)),
                              //     trailing: const Icon(Icons.chevron_right,
                              //         color: Colors.white),
                              //     onTap: () {
                              //       // Handle change password
                              //     },
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: screenHeight * 0.07,
                              // ),
                              Center(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    signOut();
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
                                        fontSize: screenWidth *
                                            screenHeight *
                                            0.00006,
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
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      title: const Text(
        'ΠΡΟΦΙΛ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
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
}
