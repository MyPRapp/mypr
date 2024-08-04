import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BottomNavBarVisibility(),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ClubProvider()),
          ChangeNotifierProvider(create: (_) => BottomNavBarVisibility()),
          // Add other providers here
        ],
        child: const MyPR(),
      ),
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
      routerConfig: appRouter.config(),
    );
  }
}
