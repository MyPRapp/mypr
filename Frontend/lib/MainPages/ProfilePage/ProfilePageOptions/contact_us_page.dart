import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/global_state_provider.dart';
import '../../../global_components.dart';

@RoutePage()
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
      if (context.read<GlobalStateProvider>().isAuthenticated) {
        setState(() {
          isAuthenticated = true;
        });
      }
    });
  }

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  Future<void> _launchInstagram() async {
    const String username = 'mypr_app';

    final Uri instagramAppUri =
        Uri.parse('instagram://user?username=$username');
    final Uri instagramWebUri =
        Uri.parse('https://www.instagram.com/$username/');

    try {
      final bool canLaunchApp = await canLaunchUrl(instagramAppUri);
      if (canLaunchApp) {
        await launchUrl(instagramAppUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(instagramWebUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('\x1B[31mCould not launch Instagram: $e');
    }
  }

  // Email validation function using regex
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    UserInfoStruct? userProvider = context.read<UserProvider>().userDetails;
    if (isAuthenticated) {
      nameController.text =
          '${userProvider.firstName} ${userProvider.lastName}';
      emailController.text = userProvider.email;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: _buildAppBar(context),
            backgroundColor: const Color.fromARGB(200, 37, 37, 37),
            body: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Τηλεφώνησε μας',
                                    style: TextStyle(
                                      color: Color(0xFF9C0C04),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  const Text(
                                    ' 69 43784099\n\n 69 80984213',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: screenHeight * 0.07),
                              child: Column(children: [
                                const Text(
                                  'Ωράριο επικοινωνίας',
                                  style: TextStyle(
                                    color: Color(0xFF9C0C04),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                const Text(
                                  'Δευτέρα-Πέμπτη\n10πμ-8μμ\n\nΠαρασκευή-Κυριακή\n2μμ-3πμ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Στείλε ένα email',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildTextField(
                                  'Ονοματεπώνυμο', 1, nameController),
                              SizedBox(height: screenHeight * 0.022),
                              _buildTextField(
                                  'Το email σου', 1, emailController),
                              SizedBox(height: screenHeight * 0.022),
                              _buildTextField('Μήνυμα', 4, messageController),
                              SizedBox(height: screenHeight * 0.035),
                              Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (messageController.text.isEmpty) {
                                      floatingSnackBar(
                                        message:
                                            'Το μήνυμα δεν μπορεί να είναι άδειο',
                                        context: context,
                                      );
                                      return;
                                    }

                                    if (!_isValidEmail(emailController.text)) {
                                      floatingSnackBar(
                                        message:
                                            'Παρακαλώ συμπληρώστε email επικοινωνίας',
                                        context: context,
                                      );
                                      return;
                                    }

                                    if (nameController.text.isEmpty) {
                                      floatingSnackBar(
                                        message:
                                            'Παρακαλώ συμπληρώστε ονοματεπώνυμο',
                                        context: context,
                                      );
                                      return;
                                    }

                                    // Show the confirmation dialog
                                    await _showConfirmationDialog(context);
                                  },
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(screenHeight * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Στείλε μήνυμα\nστο instagram',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  GestureDetector(
                                    onTap: _launchInstagram,
                                    child: const ImageIcon(
                                      AssetImage(
                                          'assets/icons/instagram_icon.png'),
                                      size: 40,
                                      color: Color(0xFF9C0C04),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: screenWidth / 2.5,
                                child: Image.asset(
                                  'assets/otherPhotos/Logo_v2.2-removebg(cropped).png',
                                  height: screenHeight / 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      title: const Text(
        'ΕΠΙΚΟΙΝΩΝΗΣΕ ΜΑΖΙ ΜΑΣ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Επιβεβαίωση'),
          content: const Text('Αποστολή μηνύματος;'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose "Cancel"
              },
              child: const Text('Ακύρωση'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose "Send"
              },
              child: const Text('Αποστολή'),
            ),
          ],
        );
      },
    );

    // If the user confirmed, proceed with sending the message
    if (result == true) {
      _sendMessage(); // Call the method to send the message
    }
  }

  Future<void> _sendMessage() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (mounted) {
      floatingSnackBar(
        message: 'Σφάλμα κατά την αποστολή του μηνύματος',
        context: context,
      );
    }

    try {
      final response = await http
          .post(
        Uri.parse(
            'http://${GlobalStateProvider().validatedIp}/api/send-email/'),
        headers: {
          'Content-Type':
              'application/json', //TODO Remove access token requirement from send-email function
          // 'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'subject': nameController.text.trim(),
          'sender_email': emailController.text.trim(),
          'message': messageController.text.trim(),
        }),
      )
          .timeout(const Duration(seconds: 8), onTimeout: () {
        print('\x1B[31mError on email sending: Timeout exception');
        return http.Response('Error: Timeout', 408);
      });

      if (response.statusCode == 200) {
        if (mounted) {
          print('\x1B[32mEmail sent successfully');
          floatingSnackBar(
            message: 'Το μήνυμα στάλθηκε',
            context: context,
          );
        }
      } else {
        if (mounted) {
          print('\x1B[31mError on email sending');
          floatingSnackBar(
            message: 'Σφάλμα κατά την αποστολή του μηνύματος',
            context: context,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        floatingSnackBar(
          message: 'Σφάλμα κατά την αποστολή του μηνύματος',
          context: context,
        );
      }
    }
  }

  // TextField builder method for form inputs
  Widget _buildTextField(
      String hintText, int maxLines, TextEditingController controller) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        hintFadeDuration: const Duration(milliseconds: 300),
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
