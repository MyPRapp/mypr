import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    _controller.addListener(() => _filterClubs(_controller.text));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubs = context
          .read<ClubProvider>()
          .allClubs
          .map((club) => club.clubName)
          .toList();
    });
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

      final clubProvider = context.read<ClubProvider>();
      final club = clubProvider.getClubByName(clubName);
      final catalogues = clubProvider.getCataloguesByClubID(club.clubID);

      AutoRouter.of(context)
          .push(ReservationRoute(club: club, catalogues: catalogues));
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = ScreenUtil().screenHeight;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownVisible = false;
              FocusManager.instance.primaryFocus?.unfocus();
            });
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
              padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 80.h),
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 70.h),
                      _buildDropdownList(screenHeight),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        setState(
                            () => _isDropdownVisible = !_isDropdownVisible);
                      },
                      child: _buildSearchField()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 50.h),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255), fontSize: 17.sp),
        decoration: InputDecoration(
          hintText: 'Βρες που θα παρτάρεις',
          hintStyle: TextStyle(
              color: const Color.fromARGB(255, 182, 176, 176), fontSize: 15.sp),
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: 5.w),
            child: Icon(Icons.search, color: Colors.grey, size: 15.sp),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: const Color.fromARGB(255, 158, 158, 158),
                    size: 15.sp,
                  ),
                  onPressed: _clearSearchField,
                )
              : null,
        ),
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
            color: const Color.fromARGB(255, 0, 0, 0),
            border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
            borderRadius: BorderRadius.all(Radius.circular(10.r)),
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
                      contentPadding:
                          EdgeInsets.only(left: 12.sp, top: 3.sp, bottom: 3.sp),
                      title: Text(clubName,
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.sp)),
                      onTap: () => _onClubTap(clubName),
                    ),
                    if (index != _filteredClubs.length - 1)
                      Divider(
                          thickness: 1.sp,
                          color: const Color.fromARGB(189, 110, 110, 110)),
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
