import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/Widgets/home_page_widgets.dart';
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
    await Future.wait([_syncUser(), _fetchClubs()]);
  }

  Future<void> _fetchClubs() async {
    warningPrint('------------SYNCING CLUBS------------');
    await context.read<ClubProvider>().fetchAndSaveClubsAndCatalogues();
    successPrint('------------SYNCED CLUBS------------');
  }

  Future<void> _syncUser() async {
    final globalStateProvider = context.read<GlobalStateProvider>();

    if (mounted && globalStateProvider.preferencesLoaded) {
      if (globalStateProvider.isAuthenticated) {
        await _attemptUserLogin();
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
      final loggedIn = await AuthService().login(savedEmail, savedPassword);
      if (mounted) {
        final globalStateProvider = context.read<GlobalStateProvider>();

        if (loggedIn && mounted) {
          globalStateProvider.isAuthenticated = true;
          await userProvider.fetchUserDetailsFromServer();
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

  void navigateToSearchTab(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    if (tabsRouter.activeIndex != 1) {
      tabsRouter.setActiveIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: _backgroundGradient(),
          height: screenHeight,
          width: screenWidth,
          child: RefreshIndicator.adaptive(
            color: const Color(0xFF9C0C04),
            onRefresh: _initApp,
            child: ListView(
              children: [
                _buildHeader(screenHeight, screenWidth),
                _buildResultsTitle(screenHeight, screenWidth), //TODO
                _buildClubList(screenHeight, screenWidth),
                // _buildComingSoonText(), //TODO
                SizedBox(height: screenHeight / 40 * 6),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildHeader(double screenHeight, double screenWidth) {
    return SizedBox(
      height: screenHeight / 13,
      width: screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(screenHeight, screenWidth),
          _buildSearchBox(screenHeight, screenWidth),
        ],
      ),
    );
  }

  Widget _buildLogo(double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.02),
      child: Image.asset(
        'assets/otherPhotos/Logo_v2.2-removebg(cropped).png',
        height: screenHeight / 13,
        width: screenWidth / 4,
      ),
    );
  }

  Widget _buildSearchBox(double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(right: screenWidth * 0.02),
      child: GestureDetector(
        onTap: () => navigateToSearchTab(context),
        child: Container(
          //TODO Make this container fixed depending on 3 or 4 screen resolutions
          alignment: Alignment.center,
          height: screenHeight / 17,
          width: screenWidth / 2.65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 0, 0, 0),
                Color.fromARGB(150, 55, 55, 55),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          // child: const TextField(
          // enabled: false,
          // decoration: InputDecoration(
          //   hintText: 'Αναζήτηση',
          //   hintStyle: TextStyle(color: Colors.grey),
          //   filled: true,
          //   fillColor: Colors.transparent,
          //   border: OutlineInputBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(8)),
          //     borderSide: BorderSide.none,
          //   ),
          //   prefixIcon: Icon(Icons.search, color: Colors.grey),
          // ),
          // ),
        ),
      ),
    );
  }

  Widget _buildResultsTitle(double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.03,
        top: screenHeight * 0.035,
        bottom: screenHeight * 0.02,
      ),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [
            Color.fromARGB(255, 56, 56, 56),
            Color.fromARGB(255, 162, 162, 162),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.center,
        ).createShader(bounds),
        // child:
        //  Text(
        //   'Όλα τα αποτελέσματα',
        //   style: TextStyle(
        //     fontSize: screenWidth * 0.02 + screenHeight * 0.0125,
        //     fontWeight: FontWeight.bold,
        //     color: Colors.white,
        //   ),
        // ),
      ),
    );
  }

  Widget _buildClubList(double screenHeight, double screenWidth) {
    return Consumer<ClubProvider>(
      builder: (context, clubProvider, _) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: clubProvider.allClubs.length,
          itemBuilder: (context, index) {
            final club = clubProvider.allClubs[index];
            if (club.clubPhoto.isNotEmpty || club.localPhotoPath.isNotEmpty) {
              return BigClubCard(
                key: ValueKey(club.clubID),
                club: club,
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  // Widget _buildComingSoonText() {
  //   return const Text(
  //     textAlign: TextAlign.center,
  //     'Περισσότερα club έρχονται σύντομα...',
  //     style: TextStyle(
  //       color: Colors.grey,
  //       fontSize: 15,
  //       fontWeight: FontWeight.w600,
  //     ),
  //   );
  // }
}
