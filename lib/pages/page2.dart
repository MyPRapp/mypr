import 'package:flutter/material.dart';

class SykoRoute extends StatelessWidget {
  SykoRoute({super.key});
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sykos'),
          backgroundColor: const Color(0xFF9c0c04),
        ),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                    fit: BoxFit.fill)),
          ),
          ListView(controller: _scrollController, children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/clubPhotos/Syko.jpg'),
                        fit: BoxFit.fill)),
              ),
            ),
            const Padding(
              padding: const EdgeInsets.all(12.0),
              child: const Text(
                'Φιάλες και Τιμές',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ]),
        ]));
  }
}

class BlastRoute extends StatelessWidget {
  const BlastRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blast Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate back to first route when tapped.
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
