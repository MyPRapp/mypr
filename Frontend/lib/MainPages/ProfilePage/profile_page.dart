import 'dart:convert';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/profile_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<ImageProvider> _loadUserPhoto(String photoPath) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? base64Photo = prefs.getString('user_photo');
      if (base64Photo != null) {
        // Decode the base64 string and return a MemoryImage
        final Uint8List bytes = base64Decode(base64Photo);
        return MemoryImage(bytes);
      }
      // Fallback to loading the image from the network
      return NetworkImage(
          'http://${GlobalState().validatedIp}:8000/$photoPath');
    } catch (e) {
      // Fallback to a default asset if an error occurs
      return const AssetImage('assets/images/default_user_image.png');
    }
  }

  @override
  void initState() {
    super.initState();
    UserProvider userProvider = context.read<UserProvider>();
    userProvider.loadUserDetailsFromPreferences();
  }

  Future<void> _refresh() async {
    UserProvider userProvider = context.read<UserProvider>();
    userProvider.fetchUserDetailsFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final userDetails = context.watch<UserProvider>().userDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
    });
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: userDetails == null
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                height: screenHeight,
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                      width: screenWidth,
                      child: const Image(
                        image: AssetImage('assets/otherPhotos/IMG_0041.jpg'),
                        fit: BoxFit.fitWidth,
                        alignment: Alignment(0, -0.3),
                      ),
                    ),
                    if (userDetails.photo.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.only(top: 35),
                        child: SizedBox(
                          height: 130,
                          width: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: FutureBuilder<ImageProvider>(
                              future: _loadUserPhoto(userDetails.photo),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return Image(
                                    image: snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    if (userDetails.photo.isEmpty)
                      Container(
                        padding: const EdgeInsets.only(top: 35),
                        child: SizedBox(
                          height: 130,
                          width: 130,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(300),
                            child: Container(
                              color: const Color(0xFF9C0C04),
                              child: const Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        '${userDetails.firstName} ${userDetails.lastName}',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF9c0c04),
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 25),
                      child: Divider(
                          height: 60,
                          color: Color.fromARGB(255, 99, 11, 4),
                          thickness: 10),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            AutoRouter.of(context)
                                .push(const CustomizeProfileRoute());
                          },
                          child: const ProfileOptions(
                              label: ' Επεξεργασία Προφίλ',
                              widgetIcon: ImageIcon(
                                  AssetImage("assets/icons/settings_icon.png"),
                                  color: Color(0xFF9c0c04))),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            AutoRouter.of(context)
                                .push(const MyBookingsRoute());
                          },
                          child: const ProfileOptions(
                              label: ' Οι κρατήσεις μου',
                              widgetIcon: ImageIcon(
                                  AssetImage("assets/icons/book_icon.png"),
                                  color: Color(0xFF9c0c04))),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            AutoRouter.of(context).push(const FavoritesRoute());
                          },
                          child: const ProfileOptions(
                              label: ' Αγαπημένα',
                              widgetIcon: ImageIcon(
                                AssetImage(
                                    "assets/icons/heart(liked)_icon.png"),
                                color: Color(0xFF9c0c04),
                              )),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () {
                            AutoRouter.of(context).push(const ContactUsRoute());
                          },
                          child: const ProfileOptions(
                              label: ' Επικοινωνήστε μαζί μας',
                              widgetIcon: ImageIcon(
                                  AssetImage("assets/icons/support_icon.png"),
                                  color: Color(0xFF9c0c04))),
                        )
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
