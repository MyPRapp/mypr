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
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final BookingService _bookingService = BookingService();
  // Function to handle form submission
  _submitForm() async {
    String date = _dateController.text.trim();
    String time = _timeController.text.trim();
    String notes = _notesController.text.trim();
    bool success = await _bookingService.submitForm(date, time, notes);
    if (success) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      // Show error
    }

    // Clear the form fields
    _dateController.clear();
    _timeController.clear();
    _notesController.clear();
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
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Booking Date'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Time input field
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Booking Time'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Notes input field
              TextFormField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Additional Notes'),
                keyboardType: TextInputType.text,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
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
