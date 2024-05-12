import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/Widgets/reservation_page_widgets.dart';

@RoutePage()
class ReservationPage extends StatelessWidget {
  const ReservationPage({super.key, required this.clubName});

  final String clubName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(clubName),
          backgroundColor: const Color(0xFF9c0c04),
        ),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                    fit: BoxFit.fill)),
          ),
          ListView(children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/clubPhotos/$clubName.jpg'),
                        fit: BoxFit.fill)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Φιάλες και Τιμές',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const BuildInfoCard(package: 'Απλό', maxPersons: 5, minPrice: 110),
            const SizedBox(
              height: 20,
            ),
            const BuildInfoCard(package: 'Απλό', maxPersons: 5, minPrice: 110),
            const SizedBox(
              height: 20,
            ),
            const BuildInfoCard(package: 'Απλό', maxPersons: 5, minPrice: 110),
          ]),
        ]));
  }
}
