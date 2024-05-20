import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/profile_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ΠΡΟΦΙΛ',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        ),
        backgroundColor: const Color(0xFF9c0c04),
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50),
            child: const Icon(
              Icons.account_circle_outlined,
              size: 100,
              color: Color(0xFF9c0c04),
            ),
          ),
          const Text(
            'Αντώνιος Παπαρδελης',
            style: TextStyle(
                fontSize: 20,
                color: Color(0xFF9c0c04),
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 100, color: Color(0xFF1e0604), thickness: 10),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  AutoRouter.of(context).push(const CustomiseProfileRoute());
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
                  AutoRouter.of(context).push(const MyReservationsRoute());
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
                  AutoRouter.of(context).push(const FavouritesRoute());
                },
                child: const ProfileOptions(
                    label: ' Αγαπημένα',
                    widgetIcon: ImageIcon(
                      AssetImage("assets/icons/heart(liked)_icon.png"),
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }
}
