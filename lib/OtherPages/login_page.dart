import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(children: [
          SizedBox(
            height: 40,
            width: double.maxFinite,
            child: Image(
              image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
              fit: BoxFit.fitWidth,
              alignment: Alignment(0, -0.3),
            ),
          ),
          SizedBox(height: 40),
          Stack(children: [
            SizedBox(
                height: 123,
                width: 220,
                child: Image(
                    image: AssetImage('assets/launch_icon/Logo_v2.2.png'),
                    fit: BoxFit.contain)),
            Text('Καλώς όρισες στην',
                style: TextStyle(
                  color: Color(0xFF9c0c04),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ))
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.only(right: 185),
              child: SizedBox(
                child: Text('Συνδέσου.',
                    style: TextStyle(
                      color: Color(0xFF9c0c04),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    )),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 35,
              width: 300,
              child: TextField(
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Email/Τηλέφωνο(+30)',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(180, 156, 12, 4),
                    ),
                    border: InputBorder.none,
                  )),
            ),
            SizedBox(
              width: 300,
              child: Divider(
                  height: 10,
                  color: Color.fromARGB(60, 156, 12, 4),
                  thickness: 7),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 35,
              width: 300,
              child: TextField(
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Κωδικός',
                    hintStyle: TextStyle(
                      color: Color.fromARGB(180, 156, 12, 4),
                    ),
                    border: InputBorder.none,
                  )),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 30),
              child: SizedBox(
                height: 30,
                width: 330,
                child: Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        'Δεν έχεις λογαριασμό; ',
                        style: TextStyle(
                            color: Color(0xFF9C0C04),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: Text(
                        'Κάνε εγγραφή.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 78, top: 5),
              child: SizedBox(
                width: 220,
                child: Text(
                  'Ξέχασες τον κωδικό σου;',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
