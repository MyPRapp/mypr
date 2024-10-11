import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
import 'package:mypr/global_components.dart';
import 'package:provider/provider.dart';

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
    _initApp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
    });
  }

  Future<void> _initApp() async {
    _initUser();
    _fetchClubs();
  }

  Future<void> _fetchClubs() async {
    warningPrint('------------SYNCING CLUBS------------');
    if (mounted) {
      await context.read<ClubProvider>().fetchAndSaveClubsAndCatalogues();
    }
    successPrint('------------SYNCED CLUBS------------');
  }

  Future<void> _initUser() async {
    GlobalStateProvider globalStateProvider =
        context.read<GlobalStateProvider>();
    UserProvider userProvider = context.read<UserProvider>();

    if (mounted && globalStateProvider.preferencesLoaded) {
      if (globalStateProvider.isAuthenticated) {
        successPrint('------------USER IS AUTHENTICATED------------');
        userProvider.loadUserDetailsFromPreferences();

        // Await the Future to resolve and get the String values from shared preferences
        String savedEmail = await getSavedEmail();
        String savedPassword = await getSavedPassword();

        if (savedEmail.isNotEmpty && savedPassword.isNotEmpty) {
          bool loggedIn = await AuthService().login(savedEmail, savedPassword);

          if (loggedIn && mounted) {
            context.read<GlobalStateProvider>().isAuthenticated = true;
            await userProvider.fetchUserDetailsFromServer();
          } else {
            errorPrint('Email or Password is incorrect');
          }
        } else {
          errorPrint('Email or Password is empty');

          if (mounted) {
            globalStateProvider.isAuthenticated = false;
          }
        }
      } else {
        errorPrint('------------USER IS NOT AUTHENTICATED------------');
        // userProvider.loadUserDetailsFromPreferences();
        // globalStateProvider.isAuthenticated = true;
      }
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _initUser();
    }
  }

  void navigateToSearchTab(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);

    // Set the active tab index to 1 (SearchNavigation)
    if (tabsRouter.activeIndex != 1) {
      tabsRouter.setActiveIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    // double statusBarHeight = MediaQuery.viewPaddingOf(context).top;
    return PopScope(
      canPop: false,
      child: Scaffold(
          body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: screenHeight,
        width: screenWidth,
        child: RefreshIndicator.adaptive(
          color: const Color(0xFF9C0C04),
          onRefresh: _initApp,
          child: ListView(
            children: [
              SizedBox(
                height: screenHeight / 13,
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.02),
                      child: Image.asset(
                        'assets/otherPhotos/Logo_v2.2-removebg(cropped).png', // Replace with your logo asset path
                        height: screenHeight / 13,
                        width: screenWidth / 4,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                      child: Container(
                        alignment: Alignment.center,
                        height: screenHeight / 17,
                        width: screenWidth / 2.65,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 0, 0, 0), // Black base color
                              Color.fromARGB(150, 55, 55,
                                  55), // Slightly lighter grey for gloss effect
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            navigateToSearchTab(context);
                          },
                          child: const TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'Αναζήτηση',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors
                                  .transparent, // Set fillColor to transparent
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.03,
                      top: screenHeight * 0.035,
                      bottom: screenHeight * 0.02),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 56, 56, 56), // Start with black
                        Color.fromARGB(
                            255, 162, 162, 162), // Transition to grey
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.center,
                    ).createShader(bounds),
                    child: Text(
                      'Όλα τα αποτελέσματα',
                      style: TextStyle(
                        fontSize: screenWidth * 0.02 + screenHeight * 0.0125,
                        fontWeight: FontWeight.bold,
                        color: Colors
                            .white, // The color is still required but won't be visible due to the ShaderMask
                      ),
                    ),
                  )),
              Consumer<ClubProvider>(
                builder: (context, clubProvider, _) {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: clubProvider.allClubs.length,
                    itemBuilder: (context, index) {
                      ClubInfoStruct club = clubProvider.allClubs[index];
                      if (club.clubPhoto.isNotEmpty ||
                          club.localPhotoPath.isNotEmpty) {
                        return BigClubCard(
                          key: ValueKey(club.clubID),
                          club: club,
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                        );
                      }
                      return null;
                    },
                  );
                },
              ),
              const Text(
                textAlign: TextAlign.center,
                'Περισσότερα club έρχονται σύντομα...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenHeight / 40 * 6)
            ],
          ),
        ),
      )),
    );
  }
}
