import 'package:flutter/material.dart';
import 'pages/clubs.dart';

void main() => runApp(MyPR());

class MyPR extends StatelessWidget {
  MyPR({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MyPR',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF000000),
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Αρχική'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Αναζήτηση'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Προφίλ')
            ],
            backgroundColor: const Color(0xFF9c0c04),
          ),
          body: Stack(children: [
            Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage('assets/clubPhotos/Untitled_Artwork.png'),
                      fit: BoxFit.cover)),
            ),
            ListView(controller: _scrollController, children: [
              const SizedBox(
                height: 25,
              ),
              const Text(
                ' Καλησπέρα Κάγκουρες!',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(splashColor: Colors.transparent),
                  child: TextField(
                    autofocus: false,
                    style: const TextStyle(fontSize: 22.0, color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Αναζήτηση',
                      contentPadding: const EdgeInsets.all(8),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                    ),
                  ),
                ),
              ),
              /*const TextField(
                    decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                )),*/
              const SizedBox(
                height: 25,
              ),
              const Text(
                ' Που θα τα πιείτε σήμερα?',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: clubNamesList.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  itemBuilder: (_, index) =>
                      clubsNearYouCard(clubNamesList[index]),
                ),
              ),
              const SizedBox(
                child: Text(
                  "Όλα τα αποτελέσματα",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Container(
                  child: Card(
                margin: const EdgeInsets.all(20),
                elevation: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 380,
                      height: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/clubPhotos/Akanthus.jpg'),
                        ),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10)),
                      ),
                    ),
                    Container(
                      height: 100,
                    )
                  ],
                ),
              ))
              /*Card(
                        color: Colors.black,
                        child: Container(
                          height: 150,
                          width: 350,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: AssetImage('assets/clubPhotos/Syko.jpg'),
                            ),
                          ),
                        ),
                      ),*/
            ]),

            //Expanded(
            //child: clubsList(clubNamesList[index]),
            //)
          ]),
        ));
  }
}

List clubNamesList = [
  'Lohan',
  'Blast',
  'Toyroom',
  'Akanthus',
  'Syko',
  'Boutique'
];
