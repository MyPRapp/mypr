import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for scroll events on the controller
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection !=
          ScrollDirection.idle) {
        _toggleTextVisibility();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<GlobalStateProvider>().hasCheckedAppVersion == false) {
        checkAppVersion(context);
      }
    });
  }

  bool _isVisible = false;
  bool _restartAnimation = false;

  void _toggleTextVisibility() {
    // Check if it's already visible to avoid triggering again
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });

      // Set a timer to automatically hide the text after 4 seconds
      Timer(const Duration(seconds: 1), () {
        setState(() {
          _isVisible = false;
        });
      });
    }
  }

  void _triggerAnimation() {
    setState(() {
      _restartAnimation = true;
    });

    Timer(const Duration(seconds: 1), () {
      setState(() {
        _restartAnimation = false;
      });
    });
  }

  Future<void> _refresh() async {
    UserProvider userProvider = context.read<UserProvider>();

    if (context.read<GlobalStateProvider>().isAuthenticated) {
      context.read<GlobalStateProvider>().isAuthenticated = true;
      await userProvider.fetchUserDetailsFromServer();

      if (mounted) {
        await context.read<BookingProvider>().fetchBookings(
            userProvider.userDetails, context.read<ClubProvider>());
      }
    }

    _triggerAnimation();
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 125, 9, 3),
          titlePadding: EdgeInsets.all(20.sp),
          actionsPadding: EdgeInsets.all(20.sp),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text(
            'Είσαι σίγουρος ότι θέλεις να αποσυνδεθείς;',
            style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w700),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Ακύρωση',
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                'Αποσύνδεση',
                style: TextStyle(
                    fontSize: 17.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                signOut();
              },
            ),
          ],
        );
      },
    );
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
  Timer? timer; // Declare a Timer object

  void startTimer() {
    // Check if the timer is already active
    if (timer != null && timer!.isActive) {
      // print("A timer is already running. Cannot start a new one.");
      return; // Exit the function, don't start a new timer
    }
    // If no timer is running, proceed with starting a new one
    canSend = false;

    timer = Timer(Duration(minutes: awaitMinutes), () {
      if (mounted) {
        awaitMinutes++;
        canSend = true;
      }
    });
  }

  Future<void> sendVerificationEmail() async {
    if (canSend) {
      startTimer();
      showFloatingSnackBar('Στάλθηκε email επιβεβαίωσης',
          const Duration(milliseconds: 4000), context);

      var response = await http.post(
        Uri.parse('$apiUrl/email-resend/'),
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
        showFloatingSnackBar('Ξαναδοκίμασε σε 1 λεπτό',
            const Duration(milliseconds: 4000), context);
      } else {
        showFloatingSnackBar('Ξαναδοκίμασε σε $awaitMinutes λεπτά',
            const Duration(milliseconds: 4000), context);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final userDetails = context.watch<UserProvider>().userDetails;

    final bool isAuthenticated =
        context.watch<GlobalStateProvider>().isAuthenticated;
    final bool hasVerifiedEmail =
        context.watch<GlobalStateProvider>().hasVerifiedEmail;
    final int points = context.watch<UserProvider>().userDetails.points;
    return PopScope(
      canPop: false,
      child: RefreshIndicator.adaptive(
        color: appRedColor,
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          body: SafeArea(
            bottom: false,
            right: false,
            left: false,
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
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: screenHeight),
                        child: Column(
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (!hasVerifiedEmail &&
                                      isAuthenticated) //top 'resend-email' banner is visible
                                    SizedBox(height: 40.h),
                                  SizedBox(height: 20.h),
                                  if (!isAuthenticated) SizedBox(height: 80.h),
                                  if (isAuthenticated)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 25.h),
                                          child: IconButton(
                                              onPressed: () {
                                                _toggleTextVisibility();
                                              },
                                              icon: const Icon(
                                                  Icons.info_outline),
                                              color: const Color.fromARGB(
                                                  255, 88, 88, 88),
                                              iconSize: 18.sp),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FadeText(
                                              _isVisible,
                                              'Πόντοι:',
                                            ),
                                            NumberScrollBox(
                                                scrollController:
                                                    _scrollController,
                                                points: userDetails.points),
                                          ],
                                        ),
                                        SizedBox(width: 10.w)
                                      ],
                                    ),
                                  SizedBox(
                                    width: screenWidth / 3.2,
                                    height: screenWidth / 3.2,
                                    child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(360.r),
                                        child:
                                            //  isAuthenticated
                                            // ? userDetails
                                            //         .localPhotoPath.isNotEmpty
                                            //     ? Image.file(
                                            //         File(userDetails
                                            //             .localPhotoPath),
                                            //         fit: BoxFit.cover,
                                            //       ) // Load from local file
                                            //     : userDetails.photo.isNotEmpty
                                            //         ? Image.network(
                                            //             'http://${GlobalStateProvider().validatedIp}${userDetails.photo}',
                                            //             fit: BoxFit.cover,
                                            //           )
                                            //         : const Image(
                                            //             image: AssetImage(
                                            //                 'assets/otherPhotos/Default_User.jpg'),
                                            //             fit: BoxFit.cover,
                                            //           )
                                            // :
                                            const Image(
                                          image: AssetImage(
                                              'assets/otherPhotos/Default_User.jpg'),
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  if (isAuthenticated) ...[
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: Text(
                                        '${userDetails.firstName} ${userDetails.lastName}',
                                        style: TextStyle(
                                          fontSize: 17.sp,
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.w),
                                    Center(
                                      child: GradientProgressBar(
                                        points: points,
                                        isVisible: _isVisible,
                                        restartAnimation: _restartAnimation,
                                      ),
                                    ),
                                  ],
                                ]),
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, left: 25.w),
                              child: Center(
                                child: SizedBox(
                                  width: 260.w,
                                  child: Column(
                                    children: [
                                      if (isAuthenticated)
                                        Column(
                                          children: [
                                            GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ProfileDialog(
                                                      name:
                                                          '${userDetails.firstName} ${userDetails.lastName}',
                                                      email: userDetails.email,
                                                      phone: userDetails.phone,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text('Το προφίλ μου',
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 170, 170, 170),
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                            ),
                                            redDivider(),
                                          ],
                                        ),
                                      if (isAuthenticated)
                                        SizedBox(height: 20.h),
                                      if (isAuthenticated)
                                        Column(
                                          children: [
                                            profileOptions(
                                                'Οι κρατήσεις μου',
                                                const MyBookingsRoute(),
                                                screenHeight,
                                                screenWidth),
                                            redDivider(),
                                          ],
                                        ),
                                      SizedBox(height: 20.h),
                                      Column(
                                        children: [
                                          profileOptions(
                                              'Αγαπημένα',
                                              const FavoritesRoute(),
                                              screenHeight,
                                              screenWidth),
                                          redDivider(),
                                        ],
                                      ),
                                      SizedBox(height: 20.h),
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
                            if (!isAuthenticated) SizedBox(height: 100.h),
                            if (!isAuthenticated)
                              GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => _showSignOutDialog(context),
                                  child: BuildSignInOrRegisterButton(
                                      context: context)),
                            if (!isAuthenticated) SizedBox(height: 50.h),
                          ],
                        ),
                      ),
                      if (isAuthenticated)
                        Column(children: [
                          Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _showSignOutDialog(context);
                              },
                              child: Container(
                                height: 45.h,
                                width: 135.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
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
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color.fromARGB(
                                        255, 145, 145, 145),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight / 5),
                        ]),
                      deleteAccountRequest(),
                      const TermsAndPrivacyPolicy(),
                    ],
                  ),
                  if (!hasVerifiedEmail && isAuthenticated)
                    EmailConfirmationNotification(
                        onResendEmail: sendVerificationEmail,
                        text: 'Παρακαλώ επιβεβαίωσε το email σου'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget redDivider() {
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Container(
        height: 2.h,
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
    );
  }

  Widget profileOptions(String label, PageRouteInfo route, double screenHeight,
      double screenWidth) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        AutoRouter.of(context).push(route);
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label,
            style: TextStyle(
                fontSize: 16.sp,
                color: const Color.fromARGB(255, 170, 170, 170),
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget deleteAccountRequest() {
    return TextButton(
      onPressed: () {
        launchUrl(
            Uri.parse(
                'https://docs.google.com/forms/d/e/1FAIpQLSepD1scoNXAQw_-t_NIt7iwkXN3Zd-OqIAQBKjjUwoabS2KXQ/viewform'),
            mode: LaunchMode.externalApplication);
      },
      child: Text(
        'Διαγραφή λογαριασμού',
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.grey,
          decorationColor: const Color.fromARGB(200, 255, 255, 255),
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
