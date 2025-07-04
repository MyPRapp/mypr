import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mypr/Globals/constants.dart';
import 'package:mypr/Providers/user_provider.dart';
import 'package:mypr/services/message_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Globals/classes.dart';
import '../../../Globals/global_components.dart';
import '../../../Navigation/bottom_nav_bar.dart';
import '../../../Providers/global_state_provider.dart';

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
    const String username = 'mypr.app';

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
      errorPrint('Could not launch Instagram: $e');
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

    User? userProvider = context.read<UserProvider>().userDetails;
    if (isAuthenticated) {
      nameController.text =
          '${userProvider.firstName} ${userProvider.lastName}';
      if (nameController.text == ' ') {
        nameController.text = '';
      }
      emailController.text = userProvider.email;
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<BottomNavBarVisibility>().show();
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: buildAppBar(context, 'ΕΠΙΚΟΙΝΩΝΗΣΕ ΜΑΖΙ ΜΑΣ'),
            backgroundColor: const Color.fromARGB(200, 37, 37, 37),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 60.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Τηλεφώνησε μας',
                              style: TextStyle(
                                color: appRedColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            SelectableText(
                              ' 698 098 4213',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SelectableText(
                              ' 698 556 7317',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 80.h),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Στείλε ένα email',
                              style: TextStyle(
                                color: appRedColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            _buildTextField('Ονοματεπώνυμο', 1, nameController),
                            SizedBox(height: 20.h),
                            _buildTextField('Το email σου', 1, emailController),
                            SizedBox(height: 20.h),
                            _buildTextField('Μήνυμα', 4, messageController),
                            SizedBox(height: 40.h),
                            ElevatedButton(
                              onPressed: () async {
                                if (messageController.text.isEmpty) {
                                  showFloatingSnackBar(
                                      'Το μήνυμα δεν μπορεί να είναι άδειο',
                                      const Duration(milliseconds: 4000),
                                      context);
                                  return;
                                }

                                if (!_isValidEmail(emailController.text)) {
                                  showFloatingSnackBar(
                                      'Παρακαλώ συμπλήρωσε email επικοινωνίας',
                                      const Duration(milliseconds: 4000),
                                      context);
                                  return;
                                }

                                if (nameController.text.isEmpty ||
                                    nameController.text == ' ') {
                                  showFloatingSnackBar(
                                      'Παρακαλώ συμπλήρωσε ονοματεπώνυμο',
                                      const Duration(milliseconds: 4000),
                                      context);
                                  return;
                                }

                                // Show the confirmation dialog
                                await _showConfirmationDialog(context);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 20, shadowColor: Colors.black,

                                backgroundColor: Colors.black,
                                // side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                'Αποστολή',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 100.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Στείλε μήνυμα\nστο instagram',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                GestureDetector(
                                  onTap: _launchInstagram,
                                  child: ImageIcon(
                                    const AssetImage(
                                        'assets/icons/instagram_icon.png'),
                                    size: 40.sp,
                                    color: appRedColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: screenWidth / 2.5,
                              child: Image.asset(
                                'assets/otherPhotos/Logo_v2.2-removebg(cropped).png',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: screenHeight / 10,
                  )
                ],
              ),
            )),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: Text('Επιβεβαίωση', style: TextStyle(fontSize: 22.sp)),
          content:
              Text('Αποστολή μηνύματος;', style: TextStyle(fontSize: 15.sp)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User chose "Cancel"
              },
              child: Text('Ακύρωση', style: TextStyle(fontSize: 18.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User chose "Send"
              },
              child: Text('Αποστολή', style: TextStyle(fontSize: 18.sp)),
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

    try {
      if (await sendEmail(nameController.text.trim(),
          emailController.text.trim(), messageController.text.trim())) {
        if (mounted) {
          showFloatingSnackBar('Το μήνυμα στάλθηκε',
              const Duration(milliseconds: 4000), context);
        }
      } else {
        if (mounted) {
          showFloatingSnackBar('Σφάλμα κατά την αποστολή του μηνύματος',
              const Duration(milliseconds: 4000), context);
        }
      }
    } catch (e) {
      if (mounted) {
        showFloatingSnackBar('Σφάλμα κατά την αποστολή του μηνύματος',
            const Duration(milliseconds: 4000), context);
      }
      errorPrint('$e');
    }
  }

  // TextField builder method for form inputs
  Widget _buildTextField(
      String hintText, int maxLines, TextEditingController controller) {
    return TextField(
      maxLines: maxLines,
      controller: controller,
      style: TextStyle(color: Colors.white, fontSize: 13.sp),
      decoration: InputDecoration(
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.2),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white54, fontSize: 13.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(13.sp),
      ),
    );
  }
}
