import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/Widgets/profile_page_widgets.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().show();
    });
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
            width: double.maxFinite,
            child: Image(
              image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment(0, -0.3),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 50),
              child: SizedBox(
                height: 130,
                width: 130,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300),
                  child: Image.asset(
                    'assets/clubPhotos/giorgos_sto_plintirio.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          const Padding(
            padding: EdgeInsets.only(top: 30.0),
            child: Text(
              'Αντώνιος Παπαρδελης',
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF9c0c04),
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 50),
            child: Divider(
                height: 100,
                color: Color.fromARGB(255, 99, 11, 4),
                thickness: 10),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  AutoRouter.of(context).push(const CustomizeProfileRoute());
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
                  AutoRouter.of(context).push(const FavoritesRoute());
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
              )
            ],
          ),
        ],
      ),
    );
  }
}
