import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mypr/Providers/global_state_provider.dart';
import 'package:mypr/global_components.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:provider/provider.dart';

import 'Providers/booking_provider.dart';
import 'Providers/club_provider.dart';
import 'Providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavBarVisibility()),
        ChangeNotifierProvider(create: (_) => GlobalStateProvider()),
      ],
      child: const MyPR(),
    ),
  );

  // Start syncing clubs as soon as the app launches
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await startSyncingClubs();
  });
}

Future<void> startSyncingClubs() async {
  // Fetch the context of the current app to access the providers
  final context = MyPR.navigatorKey.currentContext;
  if (context != null) {
    final globalState = context.read<GlobalStateProvider>();
    if (!globalState.dataLoaded) {
      final clubProvider = context.read<ClubProvider>();
      await clubProvider.syncClubs();
      globalState.setDataLoaded(true);
    }
  }
}

class MyPR extends StatelessWidget {
  const MyPR({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

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
        // Add other supported locales here
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
