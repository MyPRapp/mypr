import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Globals/global_components.dart';
import '../../Providers/booking_provider.dart'; // Import the BookingProvider
import '../../Providers/global_state_provider.dart';
import '../../Providers/liked_clubs_provider.dart';
import '../../Providers/user_provider.dart';
import '../../Widgets/profile_page_widgets.dart';
import '../../services/auth_service.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int points = 0;
  bool isVerified = false;

  @override
  void initState() {
    super.initState();
    points = context.read<UserProvider>().userDetails.points;
  }

  Future<void> _refresh() async {
    UserProvider userProvider = context.read<UserProvider>();

    // Await the Future to resolve and get the String values from shared preferences
    String savedEmail = await getSavedEmail();
    String savedPassword = await getSavedPassword();

    if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      bool loggedIn = await AuthService().login(savedEmail, savedPassword);

      if (loggedIn && mounted) {
        context.read<GlobalStateProvider>().isAuthenticated = true;
        await userProvider.fetchUserDetailsFromServer();

        if (mounted) {
          await context.read<BookingProvider>().fetchBookings(
              userProvider.userDetails, context.read<ClubProvider>());
        }
      }
    }
    if (points != 0) {
      setState(() {
        points = 0;
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      points = userProvider.userDetails.points;
    });
  }

  void signOut() async {
    try {
      warningPrint('------------SIGNING OUT------------');

      // Step 1: Get SharedPreferences instance for key-value data
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Step 2: Retain specific keys and their values (excluding liked clubs)
      final String? validatedIp = prefs.getString('validatedIp');
      // final String? savedEmail = prefs.getString('savedEmail');
      // final String? savedPassword = prefs.getString('savedPassword');

      // Step 3: Clear all preferences
      await prefs.clear();
      successPrint('Shared preferences cleared.');

      // Step 4: Restore the retained preferences (excluding liked clubs)
      if (validatedIp != null) {
        await prefs.setString('validatedIp', validatedIp);
        successPrint('Retained validatedIp: $validatedIp');
      }
      // if (savedEmail != null) {
      //   await prefs.setString('savedEmail', savedEmail);
      //   successPrint('Retained savedEmail: $savedEmail');
      // }
      // if (savedPassword != null) {
      //   await prefs.setString('savedPassword', savedPassword);
      //   successPrint('Retained savedPassword: $savedPassword');
      // }

      // Step 5: Clear liked clubs
      if (mounted) {
        warningPrint('Clearing liked clubs...');
        await context.read<LikedClubsProvider>().deleteAllLiked();
      }

      // Step 6: Clear bookings and reset flags
      if (mounted) {
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
      if (mounted) {
        context.read<GlobalStateProvider>().isAuthenticated = false;
        successPrint('\'isAuthenticated\' flag set to false.');
      }
      // Step 8: Reset saved user details
      if (mounted) {
        context.read<UserProvider>().resetUserDetails();
        successPrint('Successfully restored user details.');
      }

      // Step 9: Navigate to the Login page
      if (mounted) {
        warningPrint('Navigating to the login page...');
        AutoRouter.of(context).replaceAll([const LoginRoute()]);
        successPrint('Navigation to login page successful.');
      }
      successPrint('------------SIGNED OUT------------');
    } catch (e) {
      errorPrint('Error during sign out: $e');
    }
  }

  int awaitMinutes = 1;
  bool canSend = true;
  void startTimer() async {
    setState(() {
      canSend = false;
    });
    await Future.delayed(Duration(minutes: awaitMinutes));
    setState(() {
      awaitMinutes++;
      canSend = true;
    });
  }

  Future<void> sendVerificationEmail() async {
    if (canSend) {
      startTimer();
      floatingSnackBar(
          message: 'Στάλθηκε email επιβεβαίωσης', context: context);
      var response = await http.get(
        Uri.parse('$apiUrl/user-auth-status/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await getAccessToken()}',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        successPrint(response.body);
      } else {
        errorPrint('${response.statusCode}');
        errorPrint(response.body);
      }
    } else {
      if (awaitMinutes == 1) {
        floatingSnackBar(message: 'Ξαναδοκίμασε σε 1 λεπτό', context: context);
      } else {
        floatingSnackBar(
            message: 'Ξαναδοκίμασε σε $awaitMinutes λεπτά', context: context);
      }
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
      child: RefreshIndicator.adaptive(
        color: const Color(0xFF9C0C04),
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          body: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                  Color.fromARGB(153, 48, 2, 2),
                  Color.fromARGB(69, 0, 0, 0),
                ]),
              ),
              child: Stack(
                children: [
                  ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (!isVerified && isAuthenticated)
                            SizedBox(height: screenHeight * 0.02),
                          SizedBox(height: screenHeight * 0.02),
                          if (isAuthenticated)
                            Padding(
                              padding: const EdgeInsets.only(right: 25),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FadeText(
                                    points: userDetails.points,
                                  )),
                            ),
                          SizedBox(
                            height: screenWidth * screenHeight * 0.0004,
                            width: screenWidth * screenHeight * 0.0004,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(300),
                                child: isAuthenticated
                                    ? userDetails.localPhotoPath.isNotEmpty
                                        ? Image.file(
                                            File(userDetails.localPhotoPath),
                                            fit: BoxFit.cover,
                                          ) // Load from local file
                                        : userDetails.photo.isNotEmpty
                                            ? Image.network(
                                                'http://${GlobalStateProvider().validatedIp}${userDetails.photo}',
                                                fit: BoxFit.cover,
                                              )
                                            : const Image(
                                                image: AssetImage(
                                                    'assets/otherPhotos/Default_User.jpg'))
                                    : const Image(
                                        image: AssetImage(
                                            'assets/otherPhotos/Default_User.jpg'))),
                          ),
                          if (isAuthenticated)
                            Padding(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.03),
                              child: Text(
                                '${userDetails.firstName} ${userDetails.lastName}',
                                style: TextStyle(
                                  fontSize:
                                      screenHeight * 0.02 + screenWidth * 0.01,
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (isAuthenticated)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: GradientProgressBar(points: points),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.05),
                        child: Center(
                          child: SizedBox(
                            width: screenWidth *
                                0.85, // Adjust the width as needed

                            child: Column(
                              children: [
                                if (isAuthenticated)
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ProfileDialog(
                                            name:
                                                '${userDetails.firstName} ${userDetails.lastName}',
                                            email: userDetails.email,
                                            phone: userDetails.phone,
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.02,
                                          bottom: screenHeight * 0.02,
                                          top: screenHeight * 0.02),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Το προφίλ μου',
                                            style: TextStyle(
                                                fontSize: screenWidth *
                                                    screenHeight *
                                                    0.00006,
                                                color: const Color.fromARGB(
                                                    255, 170, 170, 170),
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ),
                                  ),
                                /*
                          if (isAuthenticated)
                            profileOptions(
                                'Το προφίλ μου',
                                const CustomizeProfileRoute(),
                                screenHeight,
                                screenWidth),
                          */
                                if (isAuthenticated)
                                  Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.withOpacity(0.6),
                                          Colors.black,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                if (isAuthenticated)
                                  profileOptions(
                                      'Οι κρατήσεις μου',
                                      const MyBookingsRoute(),
                                      screenHeight,
                                      screenWidth),
                                if (isAuthenticated)
                                  Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.withOpacity(0.6),
                                          Colors.black,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                profileOptions(
                                    'Αγαπημένα',
                                    const FavoritesRoute(),
                                    screenHeight,
                                    screenWidth),
                                Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.red.withOpacity(0.6),
                                        Colors.black,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                profileOptions(
                                    'Επικοινώνησε μαζί μας',
                                    const ContactUsRoute(),
                                    screenHeight,
                                    screenWidth),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isAuthenticated) SizedBox(height: screenHeight / 8),
                      if (isAuthenticated)
                        Center(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: signOut,
                            child: Container(
                              height: screenHeight * 0.07,
                              width: screenWidth / 2.2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                gradient: const LinearGradient(
                                    begin: Alignment.topRight,
                                    colors: [
                                      Color.fromARGB(183, 67, 2, 2),
                                      Color.fromARGB(255, 0, 0, 0),
                                    ]),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                textAlign: TextAlign.center,
                                'Αποσύνδεση',
                                style: TextStyle(
                                  fontSize:
                                      screenWidth * screenHeight * 0.00006,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      const Color.fromARGB(255, 145, 145, 145),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isAuthenticated)
                        SizedBox(
                          height: screenHeight * 0.12,
                        ),
                      if (!isAuthenticated)
                        SizedBox(height: screenHeight * 0.1),
                      if (!isAuthenticated)
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              AutoRouter.of(context)
                                  .replaceAll([const SignUpRoute()]);
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              foregroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                              backgroundColor: const Color.fromARGB(
                                  255, 217, 217, 217), // Text color
                              minimumSize: Size(screenWidth * 0.42,
                                  screenHeight * 0.06), // Button size
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  width: 4,
                                  color: Color.fromARGB(
                                      255, 0, 0, 0), // Border color
                                ),
                              ),
                            ),
                            child: Text(
                              'Εγγραφή / Σύνδεση',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (!isAuthenticated)
                        SizedBox(height: screenHeight * 0.2),
                    ],
                  ),
                  if (!isVerified && isAuthenticated)
                    EmailConfirmationNotification(
                        onResendEmail: sendVerificationEmail),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

class EmailConfirmationNotification extends StatelessWidget {
  final VoidCallback onResendEmail;

  const EmailConfirmationNotification({super.key, required this.onResendEmail});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: const Color.fromARGB(255, 255, 187, 0),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Παρακαλώ επιβεβαίωσε το email σου',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onResendEmail,
                  child: const Text(
                    'Επαναποστολή',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
