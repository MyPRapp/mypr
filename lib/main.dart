import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.dart';

void main() => runApp(const MyPR());

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
