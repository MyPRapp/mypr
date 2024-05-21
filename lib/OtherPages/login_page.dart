import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Column(children: [
        SizedBox(height: 40),
        Stack(children: [
          SizedBox(
              height: 150,
              width: 250,
              child: Image(
                  image: AssetImage('assets/launch_icon/Logo_v2.2.png'),
                  fit: BoxFit.contain)),
          Text('Καλώς όρισες στην',
              style: TextStyle(
                color: Color(0xFF9c0c04),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ))
        ]),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70),
              Text('  Κάνε εγγραφή.',
                  style: TextStyle(
                    color: Color(0xFF9c0c04),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  )),
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
                              )),
                          Divider(
                              height: 10, color: Colors.black, thickness: 2),
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
                              )),
                          Divider(
                              height: 10, color: Colors.black, thickness: 2),
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
                              )),
                          Divider(
                              height: 10, color: Colors.black, thickness: 2),
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
                              )),
                        ]),
                  ),
                ),
              ),
            ]),
      ]),
    );
  }
}
