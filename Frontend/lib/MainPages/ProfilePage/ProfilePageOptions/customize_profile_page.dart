import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class CustomizeProfilePage extends StatelessWidget {
  const CustomizeProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userDetails = context.watch<UserProvider>().userDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });

    void onBackPressed(BuildContext context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BottomNavBarVisibility>().show();
      });
    }

    return PopScope(
        onPopInvoked: (bool isPopInvoked) {
          onBackPressed(context);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF1D2428),
          body: userDetails == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: const Color(0xFF14181B),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: IconButton(
                                      onPressed: () {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          context
                                              .read<BottomNavBarVisibility>()
                                              .show();
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
                                    'ΠΡΟΦΙΛ',
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
                                Container(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: SizedBox(
                                      height: 130,
                                      width: 130,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: Image.asset(
                                          'assets/otherPhotos/giorgos_sto_plintirio.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${userDetails.firstName} ${userDetails.firstName}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userDetails.phone,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 226, 16, 5),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          userDetails.email,
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 226, 16, 5),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ]),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ρυθμίσεις λογαριασμού',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF14181B),
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              title: const Text('Προσθήκη/Αλλαγή φωτογραφίας',
                                  style: TextStyle(color: Colors.white)),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white),
                              onTap: () {
                                // Handle change email
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFF14181B),
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              title: const Text('Αλλαγή κωδικού',
                                  style: TextStyle(color: Colors.white)),
                              trailing: const Icon(Icons.chevron_right,
                                  color: Colors.white),
                              onTap: () {
                                // Handle change password
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: const BorderSide(
                                        color: Color(0xFF9C0C04), width: 2)),
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () {
                                context.router
                                    .replaceAll([const SignUpRoute()]);
                              },
                              child: const Text(
                                'Αποσύνδεση',
                                style: TextStyle(
                                  color: Color(0xFF9C0C04),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ));
  }
}
