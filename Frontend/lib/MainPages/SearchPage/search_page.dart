import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mypr/OtherPages/global_state.dart';
import 'package:mypr/routes/app_router.gr.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  static final FocusNode _focusNode = FocusNode();
  List<String> _filteredClubs = [];
  bool _isDropdownVisible = false;

  static void requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubProvider = context.watch<ClubProvider>();

    void filterClubs(String query) {
      final List<String> clubs =
          clubProvider.allClubs.map((club) => club.clubName).toList();
      setState(() {
        if (query.isEmpty) {
          _filteredClubs = clubs.take(5).toList();
        } else {
          _filteredClubs = clubs
              .where((club) => club.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        _isDropdownVisible = _filteredClubs.isNotEmpty;
      });
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isDropdownVisible = false;
          });
          FocusScope.of(context).unfocus();
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
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: filterClubs,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Search for clubs',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.black,
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
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: ListView.builder(
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
                              club: clubProvider.getClubByName(clubName),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
