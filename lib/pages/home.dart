import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return footer();
  }

  Scaffold footer() {
    return Scaffold(
      //appBar: Navbarmethod(),
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/Untitled_Artwork.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [searchbar()],
        ),
      ),
      bottomNavigationBar: const GNav(
        backgroundColor: Colors.black,
        color: Color(0xFF9C0C04),
        activeColor: Color(0xFF9C0C04),
        tabs: [
          GButton(
            icon: Icons.home,
            text: ' Αρχική',
          ),
          GButton(
            icon: Icons.search,
            text: ' Αναζήτησηs',
          ),
          GButton(
            icon: Icons.account_circle_outlined,
            text: ' Προφίλ',
          ),
        ],
      ),
    );
  }

  Container searchbar() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.11),
            blurRadius: 40,
            spreadRadius: 0.0)
      ]),
      child: TextField(
        decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Αναζήτηση  ',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(2),
              child: SvgPicture.asset('assets/icons/icons8-search.svg'),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none)),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  AppBar Navbarmethod() {
    return AppBar(
      title: const Text(
        'MYPR',
        style: TextStyle(
            color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0.0,
      backgroundColor: const Color(0xFF9C0C04),
      forceMaterialTransparency: true,
      leading: GestureDetector(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: SvgPicture.asset(
            'assets/icons/left-arrow-svgrepo-com.svg',
            height: 20,
            width: 20,
          ),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            width: 37,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: SvgPicture.asset(
              'assets/icons/menu-svgrepo-com.svg',
              height: 20,
              width: 20,
            ),
          ),
        ),
      ],
    );
  }
}
