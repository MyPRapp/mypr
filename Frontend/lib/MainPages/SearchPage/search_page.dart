import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Globals/structs.dart';
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
    _initializeClubs();
    _controller.addListener(() => _filterClubs(_controller.text));
  }

  void _initializeClubs() {
    _clubs = context
        .read<ClubProvider>()
        .allClubs
        .map((club) => club.clubName)
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterClubs(String query) {
    setState(() {
      _filteredClubs = query.isEmpty
          ? _clubs
          : _clubs
              .where((club) => club.toLowerCase().contains(query.toLowerCase()))
              .toList();
      _isDropdownVisible = _filteredClubs.isNotEmpty;
    });
  }

  void _clearSearchField() {
    setState(() {
      _controller.clear();
      _filterClubs('');
      _isDropdownVisible = false;
      FocusScope.of(context).unfocus();
    });
  }

  void _onClubTap(String clubName) {
    if (_isDropdownVisible) {
      setState(() {
        _isDropdownVisible = false;
        _controller.clear();
        FocusScope.of(context).unfocus();
      });
      List<CatalogueInfoStruct> catalogues = context
          .read<ClubProvider>()
          .getCataloguesByClubID(
              context.read<ClubProvider>().getClubByName(clubName).clubID);
      AutoRouter.of(context).push(ReservationRoute(
        club: context.read<ClubProvider>().getClubByName(clubName),
        catalogues: catalogues,
      ));
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
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
            setState(() => _isDropdownVisible = false);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            height: screenHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(255, 39, 39, 39)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.04),
                  _buildSearchField(),
                  const SizedBox(height: 30),
                  _buildDropdownList(screenHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Βρες που θα παρτάρεις',
        hintStyle: const TextStyle(color: Color.fromARGB(255, 182, 176, 176)),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearSearchField,
              )
            : null,
      ),
    );
  }

  Widget _buildDropdownList(double screenHeight) {
    return AnimatedSlide(
      offset: _isDropdownVisible ? Offset.zero : const Offset(0, -0.1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: _isDropdownVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: SizedBox(
            height: screenHeight / 3,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredClubs.length,
              itemBuilder: (context, index) {
                final clubName = _filteredClubs[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(clubName,
                          style: const TextStyle(color: Colors.white)),
                      onTap: () => _onClubTap(clubName),
                    ),
                    if (index != _filteredClubs.length - 1)
                      const Divider(
                          thickness: 0.6,
                          color: Color.fromARGB(189, 110, 110, 110)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
