import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';
import '../services/points_service.dart'; // Import the service file that makes the API call



class RetractPointsScreen extends StatefulWidget {
  const RetractPointsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RetractPointsScreenState createState() => _RetractPointsScreenState();
}

class _RetractPointsScreenState extends State<RetractPointsScreen> {
  int _currentPoints = 0;
  final PointsService _pointsService = PointsService();  // Create an instance of PointsService

  Future<void> _retractPoints(int pointsToRetract) async {
    try {
      int updatedPoints = await _pointsService.retractPoints(pointsToRetract);  // Use the instance to call retractPoints
      setState(() {
        _currentPoints = updatedPoints;
      });
      Fluttertoast.showToast(
        msg: "$pointsToRetract points retracted successfully. Current points: $_currentPoints",
      );
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Failed to retract points: $error",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retract Points'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Points: $_currentPoints'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                int pointsToRetract = 50; // Specify how many points to retract
                _retractPoints(pointsToRetract);
              },
              child: const Text('Retract 50 Points'),
            ),
          ],
        ),
      ),
    );
  }
}
