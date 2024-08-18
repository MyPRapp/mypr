import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<BottomNavBarVisibility>().show();
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
                const Text(
                  'ΕΠΙΚΟΙΝΩΝΗΣΤΕ ΜΑΖΙ ΜΑΣ',
                  style: TextStyle(
                      color: Color(0xFF9C0C04),
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Row(
            children: [
              // Left section
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo.png', // Replace with your logo asset path
                        height: 50,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'CALL US',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '69-43784099\n69-80984213',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'BUSINESS HOURS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Mon-Fri.......10am-8pm\nSat, Sun.....10am-3pm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'FOLLOW US',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.camera_alt,
                              color: Colors.white,
                              size: 30), // Replace with an Instagram icon
                          SizedBox(width: 10),
                          Icon(Icons.facebook,
                              color: Colors.white,
                              size: 30), // Replace with a Facebook icon
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Middle divider
              Container(
                color: const Color(0xFF9C0C04),
                width: 10,
              ),

              // Right section
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CONTACT FORM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildTextField('Enter your name'),
                      const SizedBox(height: 20),
                      _buildTextField('Enter a valid email address'),
                      const SizedBox(height: 20),
                      _buildTextField('Enter your message', maxLines: 4),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                        child: const Text(
                          'Send',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TextField builder method for form inputs
  Widget _buildTextField(String hintText, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }
}
