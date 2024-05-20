import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 36, 36, 36),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ' Καλως όρισες!\n   Κάνε εγγραφή.',
            style: TextStyle(
              color: Color(0xFF9c0c04),
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Card(
                color: Color.fromARGB(104, 107, 107, 107),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: ' Όνομα',
                        hintStyle: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontWeight: FontWeight.w900),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.black,
                      thickness: 2,
                    ),
                    TextField(
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: ' Επίθετο',
                        hintStyle: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontWeight: FontWeight.w900),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.black,
                      thickness: 2,
                    ),
                    TextField(
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: ' Τηλέφωνο(+30)',
                        hintStyle: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontWeight: FontWeight.w900),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(
                      height: 10,
                      color: Colors.black,
                      thickness: 2,
                    ),
                    TextField(
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: ' Email',
                        hintStyle: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontWeight: FontWeight.w900),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
