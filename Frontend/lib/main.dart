import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ClubProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavBarVisibility()),
        ChangeNotifierProvider(create: (_) => GlobalState()),
      ],
      child: const MyPR(),
    ),
  );
}

class MyPR extends StatelessWidget {
  const MyPR({super.key});

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
