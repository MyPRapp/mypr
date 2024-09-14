import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mypr/Providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Providers/global_state_provider.dart';
import '../../../global_components.dart';
import '../../../services/auth_service.dart';

@RoutePage()
class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
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
      print('Could not launch Instagram: $e');
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
    UserInfoStruct? userProvider = context.read<UserProvider>().userDetails;
    nameController.text =
        '${userProvider?.firstName} ${userProvider?.lastName}';
    emailController.text = userProvider!.email;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: constraints.maxHeight / 20),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF9C0C04),
                            size: 40,
                          ),
                        ),
                      ),
                      const Text(
                        'ΕΠΙΚΟΙΝΩΝΗΣΕ ΜΑΖΙ ΜΑΣ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Left Column for phone numbers and communication hours
                                SizedBox(
                                  height: 300,
                                  width: constraints.maxWidth / 2,
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Πάρε μας τηλέφωνο',
                                        style: TextStyle(
                                          color: Color(0xFF9C0C04),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        ' 69 43784099\n 69 80984213',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Ωράριο επικοινωνίας',
                                        style: TextStyle(
                                          color: Color(0xFF9C0C04),
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Δευτέρα-Πέμπτη\n10πμ-8μμ\n\nΠαρασκευή-Κυριακή\n2μμ-3πμ',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right Column for Instagram icon and text, aligned bottom-right
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: SizedBox(
                                    height: 300,
                                    width: constraints.maxWidth / 2 - 20,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          'assets/otherPhotos/Logo_v2.2-removebg(cropped).png',
                                          height: constraints.maxHeight / 10,
                                        ),
                                        Column(
                                          children: [
                                            const Text(
                                              'Στείλε μας\nστο instagram',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xFF9C0C04),
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: _launchInstagram,
                                              child: const ImageIcon(
                                                AssetImage(
                                                    'assets/icons/instagram_icon.png'),
                                                size: 30,
                                                color: Color(0xFF9C0C04),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Στείλε μας ένα email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildTextField('Ονοματεπώνυμο', 1, nameController),
                            const SizedBox(height: 20),
                            _buildTextField('Email', 1, emailController),
                            const SizedBox(height: 20),
                            _buildTextField('Μήνυμα', 4, messageController),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (messageController.text.isEmpty) {
                                    floatingSnackBar(
                                        message:
                                            'Το μήνυμα δεν μπορεί να είναι άδειο',
                                        context: context);
                                    return;
                                  }

                                  if (!_isValidEmail(emailController.text)) {
                                    floatingSnackBar(
                                        message:
                                            'Παρακαλώ συμπληρώστε email επικοινωνίας',
                                        context: context);

                                    return;
                                  }

                                  if (nameController.text.isEmpty) {
                                    floatingSnackBar(
                                        message:
                                            'Παρακαλώ συμπληρώστε ονοματεπώνυμο',
                                        context: context);
                                    return;
                                  }

                                  final AuthService authService = AuthService();

                                  Future<void> ensureTokenIsValid() async {
                                    try {
                                      await authService.refreshAccessToken();
                                    } catch (e) {
                                      throw Exception('Token refresh failed');
                                    }
                                  }

                                  Future<String?> getAccessToken() async {
                                    await ensureTokenIsValid();
                                    return await authService.getAccessToken();
                                  }

                                  String? accessToken = await getAccessToken();
                                  if (accessToken == null) {
                                    if (context.mounted) {
                                      floatingSnackBar(
                                          message:
                                              'Σφάλμα κατά την αποστολή του μηνύματος',
                                          context: context);
                                    }
                                    return;
                                  }

                                  try {
                                    final response = await http
                                        .post(
                                      Uri.parse(
                                          'http://${GlobalStateProvider().validatedIp}:8000/api/send-email/'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $accessToken',
                                      },
                                      body: jsonEncode({
                                        'subject': nameController.text.trim(),
                                        'sender_email':
                                            emailController.text.trim(),
                                        'message':
                                            messageController.text.trim(),
                                      }),
                                    )
                                        .timeout(const Duration(seconds: 8),
                                            onTimeout: () {
                                      return http.Response(
                                          'Error: Timeout', 408);
                                    });
                                    // if(context.mounted){

                                    if (response.statusCode == 201) {
                                      if (context.mounted) {
                                        floatingSnackBar(
                                            message: 'Το μήνυμα στάλθηκε',
                                            context: context);
                                      }
                                    } else {
                                      if (context.mounted) {
                                        floatingSnackBar(
                                            message:
                                                'Σφάλμα κατά την αποστολή του μηνύματος',
                                            context: context);
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      floatingSnackBar(
                                          message:
                                              'Σφάλμα κατά την αποστολή του μηνύματος',
                                          context: context);
                                    }
                                  }
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
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
