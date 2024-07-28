import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/routes/app_router.gr.dart'; // Ensure this import

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  void _navigateToMainApp() {
    context.router.replaceAll([const BottomNavBarRoute()]);
  }

  void _navigateToPhoneLoginPage() {
    context.router.replaceAll([const PhoneLoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 60,
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment(0, -0.3),
                ),
              ),
              const Image(
                image: AssetImage(
                    'assets/clubPhotos/Screenshot 2024-07-28 021714-Photoroom.png'),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  child: Text(
                    'Δημιουργία λογαριασμού',
                    style: TextStyle(
                      color: Color(0xFF9c0c04),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        height: 50,
                        width: 190,
                        child: TextField(
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Όνομα',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(132, 156, 12, 4),
                              ),
                              border: InputBorder.none,
                            )),
                      ),
                      const SizedBox(
                        width: 20,
                        child: VerticalDivider(
                          color: Color.fromARGB(204, 156, 12, 4),
                          thickness: 7,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 190,
                        alignment: Alignment.centerLeft,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: TextField(
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Επίθετο',
                                hintStyle: TextStyle(
                                  color: Color.fromARGB(132, 156, 12, 4),
                                ),
                                border: InputBorder.none,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                const SizedBox(
                  width: 400,
                  child: TextField(
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Τηλέφωνο(+30)',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(132, 156, 12, 4),
                        ),
                        border: InputBorder.none,
                      )),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                const SizedBox(
                  width: 400,
                  child: TextField(
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(132, 156, 12, 4),
                        ),
                        border: InputBorder.none,
                      )),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
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
                                color: Color.fromARGB(132, 156, 12, 4),
                              ),
                              border: InputBorder.none,
                            )),
                      ),
                      SizedBox(
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.visibility_off_rounded,
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 400,
                  child: Divider(
                      height: 10,
                      color: Color.fromARGB(204, 156, 12, 4),
                      thickness: 7),
                ),
                SizedBox(
                  width: 400,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(
                        width: 300,
                        child: TextField(
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Επιβεβαίωση κωδικού',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(132, 156, 12, 4),
                              ),
                              border: InputBorder.none,
                            )),
                      ),
                      SizedBox(
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.visibility_off_rounded,
                            color: Color(0xFF9C0C04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 400,
                  child: Row(children: [
                    const Text(
                      'Έχεις ήδη λογαριασμό; ',
                      style: TextStyle(
                        color: Color(0xFF9C0C04),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _navigateToPhoneLoginPage,
                      child: const Text(
                        'Συνδέσου',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ]),
                ),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF9C0C04)),
                  ),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  _navigateToMainApp();
                },
                child: const Text(
                  'Εγγραφή',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 60,
                width: double.maxFinite,
                child: Image(
                  image: AssetImage('assets/clubPhotos/IMG_0041.jpg'),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment(0, -0.3),
                ),
              ),
            ]),
      ),
    );
  }
}
