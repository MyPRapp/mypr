import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalState(),
      child: const MyPR(),
    ),
  );
}

class MyPR extends StatelessWidget {
  const MyPR({super.key});
  @override
  Widget build(BuildContext context) {
    AppRouter appRouter = AppRouter();
    return MaterialApp.router(
      title: 'MyPR',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.config(),
    );
  }
}
