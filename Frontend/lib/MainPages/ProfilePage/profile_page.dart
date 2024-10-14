import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Providers/booking_provider.dart'; // Import the BookingProvider
import '../../Providers/global_state_provider.dart';
import '../../Providers/liked_clubs_provider.dart';
import '../../Providers/user_provider.dart';
import '../../global_components.dart';
import '../../services/auth_service.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    final userDetails = context.watch<UserProvider>().userDetails;

    final bool isAuthenticated =
        context.watch<GlobalStateProvider>().isAuthenticated;

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
      canPop: false,
      child: RefreshIndicator.adaptive(
        color: const Color(0xFF9C0C04),
        onRefresh: _refresh,
        child: Scaffold(
          //  backgroundColor: const Color.fromARGB(192, 37, 37, 37),
          backgroundColor: const Color.fromARGB(255, 20, 20, 20),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.bottomRight, colors: [
                Color.fromARGB(153, 48, 2, 2),
                Color.fromARGB(69, 0, 0, 0),
              ]),
            ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: screenHeight * 0.02),
                    if (isAuthenticated)
                      const Padding(
                        padding: EdgeInsets.only(right: 25),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: FadeText()),
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
                        padding: EdgeInsets.only(top: screenHeight * 0.03),
                        child: Text(
                          '${userDetails.firstName} ${userDetails.lastName}',
                          style: TextStyle(
                            fontSize: screenHeight * 0.02 + screenWidth * 0.01,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.04),
                    // const PointsProgressBar(),
                    if (isAuthenticated)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: GradientProgressBar(progress: 70),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Center(
                    child: SizedBox(
                      width: screenWidth * 0.85, // Adjust the width as needed

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
                          // Divider(
                          //   color: Colors.black,
                          //   thickness: 2,
                          //   height: screenHeight * 0.01,
                          // ),
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
                          // Divider(
                          //   color: const Color.fromARGB(255, 101, 2, 2),
                          //   thickness: 2,
                          //   height: screenHeight * 0.01,
                          // ),
                          profileOptions('Αγαπημένα', const FavoritesRoute(),
                              screenHeight, screenWidth),
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
                          // Divider(
                          //   color: Colors.black,
                          //   thickness: 2,
                          //   height: screenHeight * 0.01,
                          // ),
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
                      onTap: () {
                        signOut();
                      },
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
                            fontSize: screenWidth * screenHeight * 0.00006,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromARGB(255, 145, 145, 145),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isAuthenticated)
                  SizedBox(
                    height: screenHeight * 0.12,
                  ),
                if (!isAuthenticated) SizedBox(height: screenHeight * 0.1),
                if (!isAuthenticated)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        AutoRouter.of(context)
                            .replaceAll([const SignUpRoute()]);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        backgroundColor: const Color.fromARGB(
                            255, 217, 217, 217), // Text color
                        minimumSize: Size(screenWidth * 0.42,
                            screenHeight * 0.06), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            width: 4,
                            color: Color.fromARGB(255, 0, 0, 0), // Border color
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
                if (!isAuthenticated) SizedBox(height: screenHeight * 0.2),
              ],
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

class FadeText extends StatefulWidget {
  const FadeText({super.key});

  @override
  FadeTextState createState() => FadeTextState();
}

class FadeTextState extends State<FadeText> {
  bool _isVisible = false;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // AnimatedOpacity for fading effect
        // AnimatedOpacity(
        //   opacity: _isVisible ? 1.0 : 0.0,
        //   duration: const Duration(seconds: 1), // Fade duration
        //   child: const Text(
        //     'Shots:',
        //     style: TextStyle(
        //         color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        //   ),
        // ),
        NumberScrollBox(scrollController: _scrollController),
      ],
    );
  }
}

class NumberScrollBox extends StatelessWidget {
  final ScrollController scrollController;

  const NumberScrollBox({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.red[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController, // Use the scroll controller
            physics: const BouncingScrollPhysics(),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  '123', // Fixed number to display
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PointsProgressBar extends StatefulWidget {
  const PointsProgressBar({super.key});

  @override
  PointsProgressBarState createState() => PointsProgressBarState();
}

class PointsProgressBarState extends State<PointsProgressBar>
    with SingleTickerProviderStateMixin {
  int _points = 0;
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  int _lastCheckpointReached = 0;

  @override
  void initState() {
    super.initState();

    // Timer to increase points by 5 every second for demo purposes
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_points < 100) {
        setState(() {
          _points += 5;
        });
        _controller.forward(from: 0);
      } else {
        timer.cancel();
      }
    });

    // Animation controller for pulsing checkpoints
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    // Glow effect animation
    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double barWidth = screenWidth * 0.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Your Points Progress',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background bar
            Container(
              height: 20,
              width: barWidth,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Progress bar overlay
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 20,
              width: barWidth * (_points / 100),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Checkpoints
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  bool isReached = _points >= index * 20;

                  // Activate glow and floating text for checkpoints after the first one
                  if (isReached &&
                      index > 0 &&
                      _lastCheckpointReached < index) {
                    _lastCheckpointReached = index;
                  }

                  return AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            isReached && index > 0 ? _glowAnimation.value : 1.0,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Glow effect for reached checkpoints beyond the first one
                            if (isReached && index > 0)
                              Positioned(
                                top: -30,
                                child: Opacity(
                                  opacity: _controller.value,
                                  child: const Text(
                                    "Great!",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.yellow,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Container(
                              width: 10,
                              height: 20,
                              decoration: BoxDecoration(
                                color:
                                    isReached ? Colors.white : Colors.grey[600],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Scrolling points display
        TweenAnimationBuilder(
          tween: IntTween(begin: _points - 5, end: _points),
          duration: const Duration(milliseconds: 300),
          builder: (BuildContext context, int value, Widget? child) {
            return Text(
              '$value Points',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfileDialog extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const ProfileDialog(
      {super.key,
      required this.name,
      required this.email,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ΠΡΟΦΙΛ",
              style: TextStyle(
                color: Color(0xFF9C0C04),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 0.5,
            ),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Ονοματεπώνυμο", value: name),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Email", value: email),
            const SizedBox(height: 10),
            ProfileInfoRow(label: "Τηλέφωνο", value: phone),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9C0C04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$label:",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class GradientProgressBar extends StatefulWidget {
  final int progress;

  const GradientProgressBar({super.key, required this.progress});

  @override
  GradientProgressBarState createState() => GradientProgressBarState();
}

class GradientProgressBarState extends State<GradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showLabel = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: widget.progress.toDouble())
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _showLabel = true;
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPercentageLabel() {
    if (_animation.isCompleted) {
      setState(() {
        _showLabel = !_showLabel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressWidth = MediaQuery.of(context).size.width;
    double filledWidth = (progressWidth * _animation.value) / 100;

    return GestureDetector(
      onTap: _showPercentageLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                "${_animation.value.toInt()}%",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          Stack(
            children: [
              Container(
                width: progressWidth,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                width: filledWidth,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 87, 1, 1),
                      Colors.red.shade900
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.center,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(6, (index) {
                  bool isActive = (_animation.value >= (index * 20));

                  return Container(
                    width: 24,
                    height: 19,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color.fromARGB(162, 152, 16, 6)
                          : Colors.transparent,
                      border: Border.all(
                          color: isActive
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : const Color.fromARGB(255, 0, 0, 0),
                          width: 2),
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
