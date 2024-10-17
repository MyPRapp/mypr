import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for setting orientations
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:mypr/Providers/reservation_provider.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:provider/provider.dart';

import 'Globals/global_components.dart';
import 'Navigation/bottom_nav_bar.dart';
import 'Providers/booking_provider.dart';
import 'Providers/club_provider.dart';
import 'Providers/user_provider.dart';

void main() async {
  // Lock the app to portrait mode only
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the binding is initialized before calling SystemChrome
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait mode
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ClubProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => ReservationProvider()),
          ChangeNotifierProvider(create: (_) => BottomNavBarVisibility()),
          ChangeNotifierProvider(create: (_) => LikedClubsProvider()),
          ChangeNotifierProvider(create: (_) => GlobalStateProvider()),
        ],
        child: const MyPR(),
      ),
    );
  });
}

class MyPR extends StatefulWidget {
  const MyPR({super.key});

  @override
  State<MyPR> createState() => _MyPRState();
}

class _MyPRState extends State<MyPR> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await createFilePath();
    if (mounted) {
      ClubProvider clubProvider = context.read<ClubProvider>();
      await clubProvider.loadClubsFromFile();
      clubProvider.loadCataloguesFromFile();
    }
    if (mounted) {
      context.read<LikedClubsProvider>().loadLikedClubsFromPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();
    return MaterialApp.router(
      title: 'MyPR',
      debugShowCheckedModeBanner: false,
      locale: const Locale('el', 'GR'), // Set the default locale to Greek
      supportedLocales: const [
        Locale('el', 'GR'), // Greek
        Locale('en', 'US'), // English (Optional, you can add more locales)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter.config(),
    );
  }
}
