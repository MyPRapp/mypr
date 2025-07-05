import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:mypr/Navigation/bottom_nav_bar.dart';
import 'package:mypr/Providers/booking_provider.dart';
import 'package:mypr/Providers/club_provider.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/Providers/liked_clubs_provider.dart';
import 'package:mypr/Providers/reservation_provider.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:mypr/services/notification_service.dart';
import 'package:provider/provider.dart';

//LOGIN PAGE
//SEARCH PAGE

//TODO Change debug = false to debug = true in build.gradle.kts for debugging

void main() async {
  // Lock the app to portrait mode only
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the binding is initialized before calling SystemChrome

  await NotificationService
      .initialize(); // TODO Add notification service on a different thread for parallelism

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

  // TODO: Create threads to split start up work and optimize it
  Future<void> _initApp() async {
    await createFilePath();
    if (mounted) {
      ClubProvider clubProvider = context.read<ClubProvider>();
      await clubProvider.loadClubsFromFile();
      await clubProvider.loadCataloguesFromFile();
    }
    if (mounted) {
      context.read<LikedClubsProvider>().loadLikedClubsFromPreferences();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Base design size (e.g., iPhone 11)
      minTextAdapt: true, splitScreenMode: false,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'MyPR',
          debugShowCheckedModeBanner: false, theme: appTheme,
          locale: const Locale('el', 'GR'), // Set the default locale to Greek
          supportedLocales: const [
            Locale('el', 'GR'), // Greek
            Locale('en', 'US'), // English (Optional, you can add more locales)
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: appRouter.config(),
        );
      },
    );
  }
}

final appTheme = ThemeData(
  fontFamily: 'CALIBRI',
);
