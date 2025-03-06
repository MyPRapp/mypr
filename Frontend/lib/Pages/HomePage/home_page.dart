import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/services/message_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Navigation/bottom_nav_bar.dart';
import '../../Providers/club_provider.dart';
import '../../services/auth_service.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initSyncing();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
      context.read<GlobalStateProvider>().refreshHomePage = false;
      _checkFirstTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil().screenHeight;
    final screenWidth = ScreenUtil().screenWidth;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: _backgroundGradient(),
          height: screenHeight,
          width: screenWidth,
          child: RefreshIndicator.adaptive(
            color: const Color(0xFF9C0C04),
            onRefresh: _initSyncing,
            child: Padding(
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              child: ListView(
                children: [
                  ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: ScreenUtil().screenHeight),
                    child: Column(
                      children: [
                        SizedBox(height: 10.h),
                        _buildHeader(screenWidth),
                        SizedBox(height: 40.h),
                        _buildResultsTitle(),
                        SizedBox(height: 15.h),
                        _buildClubList(screenHeight, screenWidth),
                        _buildComingSoonText(),
                        SizedBox(height: 140.h),
                      ],
                    ),
                  ),
                  const TermsAndPrivacyPolicy()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initSyncing() async {
    checkAppVersion(context);
    Future.wait([_fetchClubs(), _syncUser()]);
  }

  Future<void> _fetchClubs() async {
    warningPrint('------------SYNCING CLUBS------------');
    await context.read<ClubProvider>().fetchAndSaveClubsAndCatalogues();
    successPrint('------------SYNCED CLUBS------------');
  }

  Future<void> _syncUser() async {
    final globalStateProvider = context.read<GlobalStateProvider>();

    if (globalStateProvider.preferencesLoaded) {
      if (globalStateProvider.isAuthenticated) {
        await _attemptUserLogin();

        String mustSendCancellationEmail =
            globalStateProvider.mustSendCancellationEmail;

        if (mustSendCancellationEmail.isNotEmpty) {
          List<String> parts = mustSendCancellationEmail
              .split("||")
              .map((e) => e.trim())
              .toList();

          if (parts.length == 2) {
            int bookingID =
                int.tryParse(parts[1]) ?? 0; // Convert to int (fallback to 0)

            if (mounted) {
              sendCancellationEmail(
                  context,
                  parts[0], //clubName
                  context
                      .read<BookingProvider>()
                      .getBookingByBookingID(bookingID));
            }
          }
        }
      } else {
        errorPrint('------------USER IS NOT AUTHENTICATED------------');
      }
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _syncUser();
    }
  }

  Future<void> _attemptUserLogin() async {
    final userProvider = context.read<UserProvider>();
    userProvider.loadUserDetailsFromPreferences();

    final savedEmail = await getSavedEmail();
    final savedPassword = await getSavedPassword();

    if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
      final loggedIn = await login(savedEmail, savedPassword);
      if (mounted) {
        final globalStateProvider = context.read<GlobalStateProvider>();

        if (loggedIn && mounted) {
          globalStateProvider.isAuthenticated = true;

          if (context.read<GlobalStateProvider>().justRegistered) {
            context.read<GlobalStateProvider>().justRegistered = false;
            emailLoop(context);
          } else {
            fetchVerifiedEmailGlobalVariable(context);
          }

          await userProvider.fetchUserDetailsFromServer();
          if (mounted) {
            await context.read<BookingProvider>().fetchBookings(
                userProvider.userDetails, context.read<ClubProvider>());
          }
          successPrint('------------USER IS AUTHENTICATED------------');
        } else {
          _showLoginError(globalStateProvider);
        }
      }
    } else {
      if (mounted) {
        _showLoginError(context.read<GlobalStateProvider>());
      }
    }
  }

  void _showLoginError(GlobalStateProvider globalStateProvider) {
    errorPrint('Email or Password is incorrect');
    globalStateProvider.isAuthenticated = false;
  }

  void navigateToSearchTab(BuildContext context) async {
    final tabsRouter = AutoTabsRouter.of(context);
    if (tabsRouter.activeIndex != 1) {
      tabsRouter.setActiveIndex(1);
    }
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasSeenDialog = prefs.getBool('hasSeenPointsDialog') ?? false;
    bool hasSentEmail = prefs.getBool('hasSentNewUserEmail') ?? false;

    if (!hasSeenDialog && mounted) {
      showPointsReminderDialog(context);
      await prefs.setBool('hasSeenPointsDialog', true);
      await prefs.setBool('hasSeenPointsDialog', true);
    }

    if (!hasSentEmail && await newUserAlertEmail()) {
      await prefs.setBool('hasSentNewUserEmail', true);
    }
  }

  BoxDecoration _backgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return SizedBox(
      height: 50.h,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          _buildSearchBox(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/otherPhotos/Logo_v2.2-removebg(cropped).png',
      width: 120.w,
    );
  }

  Widget _buildSearchBox() {
    return GestureDetector(
      onTap: () => navigateToSearchTab(context),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(150, 55, 55, 55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              color: Colors.grey,
              size: 14.sp,
            ),
            Text(
              ' Αναζήτηση',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color.fromARGB(255, 51, 51, 51),
            Color.fromARGB(255, 194, 194, 194),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.center,
        ).createShader(bounds),
        child: Text(
          ' Όλα τα αποτελέσματα',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildClubList(double screenHeight, double screenWidth) {
    return Consumer<ClubProvider>(
      builder: (context, clubProvider, _) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount:
              clubProvider.allClubs.isEmpty ? 8 : clubProvider.allClubs.length,
          itemBuilder: (context, index) {
            if (clubProvider.allClubs.isNotEmpty) {
              final club = clubProvider.allClubs[index];
              if (club.clubPhoto.isNotEmpty || club.localPhotoPath.isNotEmpty) {
                return BigClubCard(
                  key: ValueKey(club.clubID),
                  club: club,
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                );
              }
            }
            return Padding(
              padding: EdgeInsets.only(
                bottom: 30.h,
              ),
              child: Container(
                height: 140.h,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(57, 61, 61, 61),
                    borderRadius: BorderRadius.circular(10.r)),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.r),
                              topLeft: Radius.circular(10.r)),
                          child: SizedBox(
                              height: 140.h,
                              width: screenWidth * 0.3,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: appRedColor,
                                  backgroundColor: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )),
                        ),
                      ],
                    ),
                    VerticalDivider(
                        color: const Color.fromARGB(141, 34, 34, 34),
                        thickness: 2.sp),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(5.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 3.h),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComingSoonText() {
    return Text(
      'Περισσότερα club έρχονται σύντομα...',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
