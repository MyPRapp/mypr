import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Providers/club_provider.dart';
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
  late List<String> _clubs;
  List<String> _filteredClubs = [];
  bool _isDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _clubs = context
        .read<ClubProvider>()
        .allClubs
        .map((club) => club.clubName)
        .toList();

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
    if (_clubs.isEmpty) {
      setState(() {
        _filteredClubs = [];
        _isDropdownVisible = false;
      });
      return;
    }

    setState(() {
      if (query.isEmpty) {
        _filteredClubs = _clubs;
      } else {
        _filteredClubs = _clubs
            .where((club) => club.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _isDropdownVisible = _filteredClubs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
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
                  SizedBox(height: screenHeight * 0.04),
                  TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Τι ψάχνεις;',
                      hintStyle: const TextStyle(
                          color: Color.fromARGB(255, 182, 176, 176)),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _controller.clear();
                                filterClubs('');
                              },
                            )
                          : null,
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
                        height: screenHeight / 3,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
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
                                setState(() {
                                  _isDropdownVisible = false;
                                });
                                AutoRouter.of(context).push(ReservationRoute(
                                  club: context
                                      .read<ClubProvider>()
                                      .getClubByName(clubName),
                                ));
                                _controller.clear();
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
