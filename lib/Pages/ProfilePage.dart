// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:mypr/Pages/HomePage.dart';
import 'package:mypr/Widgets/BottomNavBar.dart';
import 'package:mypr/Widgets/HomePageWidgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ΠΡΟΦΙΛ'),
        backgroundColor: const Color(0xFF9c0c04),
      ),
      backgroundColor: Colors.black,
      bottomNavigationBar: const BottomNavBar(),
      body: ListView(children: [
        Container(
          padding: const EdgeInsets.only(top: 50),
          child: const Icon(
            Icons.account_circle_outlined,
            size: 150,
            color: Color(
              0xFF9c0c04,
            ),
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
        const Divider(
          height: 150,
          color: Color(0xFF1e0604),
          thickness: 10,
        ),
        const SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProfileOptions(
                label: ' Επεξεργασία Προφίλ',
                widgetIcon: ImageIcon(
                  AssetImage("assets/icons/settings_icon.png"),
                  color: Color(0xFF9c0c04),
                ),
              ),
              ProfileOptions(
                label: ' Οι κρατήσεις μου',
                widgetIcon: ImageIcon(AssetImage("assets/icons/book_icon.png"),
                    color: Color(0xFF9c0c04)),
              ),
              ProfileOptions(
                label: ' Αγαπημένα',
                widgetIcon: ImageIcon(
                  AssetImage("assets/icons/heart_icon.png"),
                  color: Color(0xFF9c0c04),
                ),
              ),
              ProfileOptions(
                label: ' Επικοινωνήστε μαζί μας',
                widgetIcon: ImageIcon(
                    AssetImage("assets/icons/support_icon.png"),
                    color: Color(0xFF9c0c04)),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class ProfileOptions extends StatelessWidget {
  const ProfileOptions(
      {super.key, required this.label, required this.widgetIcon});

  final String label;
  final ImageIcon widgetIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Gesture Detected!')));
        },
        child: Container(
          padding: const EdgeInsets.only(left: 10),
          margin: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color(
                    0xFF9c0c04,
                  ),
                  width: 5),
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          child: Row(
            children: [
              widgetIcon,
              Text(
                label,
                style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFF9c0c04),
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
  }
}
