import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});
  Future<void> _launchInstagram() async {
    // Define the Instagram URLs for app and web
    final Uri instagramAppUri = Uri.parse('instagram://user?username=mypr_app');
    final Uri instagramWebUri =
        Uri.parse('https://www.instagram.com/mypr_app/');

    // Check if the Instagram app can be launched
    if (await canLaunchUrl(instagramAppUri)) {
      // Launch Instagram app
      await launchUrl(instagramAppUri);
    } else if (await canLaunchUrl(instagramWebUri)) {
      // Fall back to launching Instagram web if the app is not installed
      await launchUrl(instagramWebUri);
    } else {
      // Handle the case where neither the app nor the web URL can be launched
      print('Could not launch Instagram');
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/otherPhotos/mustangBackground.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: IconButton(
                    onPressed: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        context.read<BottomNavBarVisibility>().show();
                      });
                      context.router.back();
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF9C0C04),
                      size: 50,
                    ),
                  ),
                ),
                const Text(
                  'ΕΠΙΚΟΙΝΩΝΗΣΤΕ ΜΑΖΙ ΜΑΣ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // Left section
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Πάρε μας τηλέφωνο',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          ' 69 43784099\n 69 80984213',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          'Ωράριο επικοινωνίας',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Δευτέρα-Πέμπτη\n10πμ-8μμ\n\nΠαρασκευή-Κυριακή\n2μμ-3πμ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 50),
                        const Text(
                          'Κάνε ένα follow',
                          style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _launchInstagram,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: ImageIcon(
                              AssetImage('assets/icons/instagram_icon.png'),
                              size: 30,
                              color: Color(0xFF9C0C04),
                            ),
                          ),
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
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Στείλε μας ένα μήνυμα',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTextField('Ονοματεπώνυμο'),
                        const SizedBox(height: 20),
                        _buildTextField('Email'),
                        const SizedBox(height: 20),
                        _buildTextField('Μήνυμα', maxLines: 4),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'Αποστολή',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Container(
              alignment: Alignment.bottomRight,
              child: Image.asset(
                'assets/otherPhotos/Logo_v2.2-removebg.png', // Replace with your logo asset path
                height: 140,
              ),
            ),
          ],
        ),
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
