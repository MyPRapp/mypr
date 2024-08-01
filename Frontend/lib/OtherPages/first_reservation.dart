import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavBarVisibility>().hide();
    });
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 22,
        showUnselectedLabels: true,
        fixedColor: Colors.black,
        backgroundColor: const Color(0xFF9c0c04),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        selectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: 'Αρχική',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            label: 'Αναζήτηση',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: 'Προφίλ',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          const SizedBox(
            height: 40,
            width: double.maxFinite,
            child: Image(
              image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment(0, -0.3),
            ),
          ),
          const SizedBox(height: 30),
          const SizedBox(
              height: 180,
              width: 250,
              child: Image(
                  image: AssetImage('assets/launch_icon/Logo_v2.2.png'),
                  fit: BoxFit.fill)),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: SizedBox(
              height: 25,
              width: double.maxFinite,
              child: Text('  Συγχαρητήρια για την πρώτη σου κράτηση!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  )),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: SizedBox(
              height: 70,
              width: double.maxFinite,
              child: Text('  Δώρο από εμάς 15% έκπτωση στην επόμενη.',
                  style: TextStyle(
                      color: Color(0xFF9c0c04),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 120),
            child: SizedBox(
              height: 50,
              width: double.maxFinite,
              child: Text('ΣΤΟΙΧΕΙΑ ΚΡΑΤΗΣΗΣ',
                  style: TextStyle(
                      color: Color(0xFF9c0c04),
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          SizedBox(
            height: 120,
            width: 500,
            child: Row(
              children: [
                const SizedBox(width: 30),
                SizedBox(
                  height: 120,
                  width: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: const Image(
                      image: AssetImage('assets/clubPhotos/Syko.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const VerticalDivider(
                  color: Color.fromARGB(108, 156, 12, 4),
                  thickness: 7,
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text(' Όνομα: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text('Γιωργάκης',
                                style: TextStyle(
                                    color: Color(0xFF9c0c04),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text(' Ημερομηνία: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text('08/06/24',
                                style: TextStyle(
                                    color: Color(0xFF9c0c04),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text(' Άτομα: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text('6',
                                style: TextStyle(
                                    color: Color(0xFF9c0c04),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text(' Φιάλες: ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0),
                          child: SizedBox(
                            height: 30,
                            child: Text('2 Premium',
                                style: TextStyle(
                                    color: Color(0xFF9c0c04),
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ]),
      ),
    );
  }
}
