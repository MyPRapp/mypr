import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:provider/provider.dart';

import '../../routes/app_router.gr.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredClubs = [];
  bool _isDropdownVisible = false;

  @override
  void initState() {
    super.initState();

    // Listen to controller changes
    _controller.addListener(() {
      filterClubs(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void filterClubs(String query) {
    final clubProvider = context.read<ClubProvider>();
    final List<String> clubs =
        clubProvider.allClubs.map((club) => club.clubName).toList();

    setState(() {
      if (query.isEmpty) {
        _filteredClubs = clubs; // Show all clubs if the query is empty
      } else {
        _filteredClubs = clubs
            .where((club) => club.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _isDropdownVisible = _filteredClubs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Close the keyboard
            setState(() {
              _isDropdownVisible = false;
            });
          },
          child: Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF9C0C04)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Τι ψάχνεις;',
                      hintStyle:
                          TextStyle(color: Color.fromARGB(255, 182, 176, 176)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                  if (_isDropdownVisible)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                      child: SizedBox(
                        height: 350, // Limit the dropdown height to 200 pixels
                        child: ListView.builder(
                          padding: EdgeInsets.zero, // Remove padding
                          shrinkWrap: true,
                          itemCount: _filteredClubs.length,
                          itemBuilder: (context, index) {
                            final clubName = _filteredClubs[index];

                            return ListTile(
                              title: Text(
                                clubName,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                AutoRouter.of(context).push(ReservationRoute(
                                  club: context
                                      .read<ClubProvider>()
                                      .getClubByName(clubName),
                                ));
                                setState(() {
                                  _isDropdownVisible = false;
                                  _controller.clear();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
