import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to manage the form state
  final TextEditingController _clubNameController = TextEditingController();
  final TextEditingController _bookingTypeController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _numberOfPeopleController = TextEditingController();
  final BookingService _bookingService = BookingService();
  // Function to handle form submission
  _submitForm() async {
    String clubName = _clubNameController.text.trim();
    String type = _bookingTypeController.text.trim();
    String bookedAt = _timeController.text.trim();
    String numberOfPeople = _numberOfPeopleController.text.trim(); 
    bool success = await _bookingService.submitForm(clubName,type,bookedAt,numberOfPeople);
    if (success) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // Show error
    }

    // Clear the form fields
    _clubNameController.clear();
    _bookingTypeController.clear();
    _timeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Date input field
              TextFormField(
                controller: _clubNameController,
                decoration: const InputDecoration(labelText: 'Club Name'),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Time input field
              TextFormField(
                controller: _bookingTypeController,
                decoration: const InputDecoration(labelText: 'Booking Type'),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Notes input field
              TextFormField(
                controller: _timeController,
                decoration:
                    const InputDecoration(labelText: 'Booked at'),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _numberOfPeopleController,
                decoration:
                    const InputDecoration(labelText: 'Number of people'),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
