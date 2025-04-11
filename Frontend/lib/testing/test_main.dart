import 'package:flutter/material.dart';
import 'package:mypr/services/notification_service.dart';
import 'package:mypr/testing/testing_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();

  runApp(MyPR());
}

class MyPR extends StatefulWidget {
  const MyPR({super.key});

  @override
  State<MyPR> createState() => _MyPRState();
}

class _MyPRState extends State<MyPR> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'TestingApp',
        debugShowCheckedModeBanner: false,
        home: TestingHomePage(
          title: 'MyPR Testing App',
        ));
  }
}
