import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

//TODO Gradient bar resolves to a padding error when first opening profile page while also logged in
//TODO App prompts user to verify email while it's already verified

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
      if (!context.read<GlobalStateProvider>().hasCheckedAppVersion) {
        checkAppVersion(context);
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Check if refreshProfilePage is true when the widget loads
    //   if (context.read<GlobalStateProvider>().refreshProfilePage) {
    //     _refresh();
    //   }
    // });

    // // Listen for further changes to refreshProfilePage
    // context.read<GlobalStateProvider>().addListener(() {
    //   if (context.read<GlobalStateProvider>().refreshProfilePage) {
    //     _refresh();
    //   }
    // });
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
      Timer(const Duration(seconds: 2), () {
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

  Future<void> _refresh(bool useAwaitFuture) async {
    if (useAwaitFuture) {
      await Future.delayed(Duration(seconds: 3));
    }
    if (mounted) {
      context.read<GlobalStateProvider>().setRefreshProfilePage(false);

      UserProvider userProvider = context.read<UserProvider>();

      if (context.read<GlobalStateProvider>().hasLoggedIn) {
        context.read<GlobalStateProvider>().setHasLoggedIn(true);
        await userProvider.fetchUserDetailsFromServer();

        if (mounted) {
          await context.read<BookingProvider>().fetchBookings(
              userProvider.userDetails, context.read<ClubProvider>());
        }
      }
      if (mounted && !context.read<GlobalStateProvider>().hasVerifiedEmail) {
        emailLoop(context);
      }

      if (!useAwaitFuture) {
        _triggerAnimation();
      }
      // if (mounted) {
      //   context.read<GlobalStateProvider>().refreshProfilePage = false;
      //   print('CANCELED');
      // }
    }
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
      final bool hasSeenDialog = prefs.getBool('hasSeenPointsDialog') ?? false;
      final bool hasSentEmail = prefs.getBool('hasSentNewUserEmail') ?? false;

      // Step 3: Clear all preferences
      await prefs.clear();
      successPrint('Shared preferences cleared.');

      // Step 4: Restore the retained preferences (excluding liked clubs)
      await prefs.setBool('hasSeenPointsDialog', hasSeenDialog);
      successPrint('Retained hasSeenDialog: $hasSeenDialog');
      await prefs.setBool('hasSentNewUserEmail', hasSentEmail);
      successPrint('Retained hasSentEmail: $hasSentEmail');

      // Step 5: Clear liked clubs
      if (mounted) {
        await context.read<LikedClubsProvider>().deleteAllLiked();
      }

      // Step 6: Clear bookings and reset flags
      if (mounted) {
        try {
          BookingProvider bookingProvider = context.read<BookingProvider>();
          bookingProvider.bookings.clear();
          bookingProvider.setLoading(false);
          successPrint('Bookings cleared');
        } catch (e) {
          errorPrint('Error clearing bookings: $e');
        }
      }

      // Step 7: Set hasLoggedIn to false
      if (mounted) {
        context.read<GlobalStateProvider>().setHasLoggedIn(false);
        successPrint('\'hasLoggedIn\' flag set to false.');
      }
      // Step 8: Reset saved user details
      if (mounted) {
        context.read<UserProvider>().resetUserDetails();
        successPrint('Successfully restored user details.');
      }

      // Step 9: Navigate to the Login page
      if (mounted) {
        AutoRouter.of(context).replaceAll([const LoginRoute()]);
        successPrint('Navigation to login page successful.');
      }
      successPrint('------------SIGNED OUT------------');
    } catch (e) {
      errorPrint('Error during sign out: $e');
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

    final bool hasLoggedIn = context.watch<GlobalStateProvider>().hasLoggedIn;
    final bool hasVerifiedEmail =
        context.watch<GlobalStateProvider>().hasVerifiedEmail;
    final int points = context.watch<UserProvider>().userDetails.points;

    if (context.watch<GlobalStateProvider>().refreshProfilePage == true) {
      _refresh(true);
    }
    return PopScope(
      canPop: false,
      child: RefreshIndicator.adaptive(
        color: appRedColor,
        onRefresh: () {
          return _refresh(false);
        },
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
                                  if ((!hasVerifiedEmail && hasLoggedIn) ||
                                      (userDetails.isBanned &&
                                          hasLoggedIn)) //top 'resend-email' banner is visible
                                    SizedBox(height: 40.h),
                                  SizedBox(height: 20.h),
                                  if (!hasLoggedIn) SizedBox(height: 80.h),
                                  if (hasLoggedIn)
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
                                            //  hasLoggedIn
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
                                  if (hasLoggedIn) ...[
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
                                      if (hasLoggedIn)
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
                                      if (hasLoggedIn) SizedBox(height: 20.h),
                                      if (hasLoggedIn)
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
                            if (!hasLoggedIn) SizedBox(height: 100.h),
                            if (!hasLoggedIn)
                              GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () => _showSignOutDialog(context),
                                  child: BuildSignInOrRegisterButton(
                                      context: context)),
                            if (!hasLoggedIn) SizedBox(height: 50.h),
                          ],
                        ),
                      ),
                      if (hasLoggedIn)
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
                          SizedBox(height: screenHeight / 10),
                        ]),
                      deleteAccountRequest(),
                      const TermsAndPrivacyPolicy(),
                      SizedBox(height: screenHeight / 6),
                    ],
                  ),
                  if (!hasVerifiedEmail && hasLoggedIn)
                    EmailConfirmationNotification(
                        text: 'Παρακαλώ επιβεβαίωσε το email σου'),
                  if (userDetails.isBanned) BannedBanner()
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
              // ignore: deprecated_member_use
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
