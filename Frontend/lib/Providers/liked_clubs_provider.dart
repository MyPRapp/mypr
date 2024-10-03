import 'package:flutter/cupertino.dart';
import 'package:mypr/global_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikedClubsProvider extends ChangeNotifier {
  final List<int> _likedClubIDs = [];

  List<ClubInfoStruct> getAllLikedClubs(List<ClubInfoStruct> clubs) {
    return clubs.where((club) => _likedClubIDs.contains(club.clubID)).toList();
  }

  // LIKED CLUBS MANAGEMENT
  void toggleLike(int clubID) {
    if (_likedClubIDs.contains(clubID)) {
      _likedClubIDs.remove(clubID);
    } else {
      _likedClubIDs.add(clubID);
    }
    saveLikedClubsToPreferences();
    notifyListeners();
  }

  bool isLiked(int clubID) {
    return _likedClubIDs.contains(clubID);
  }

  Future<void> deleteAllLiked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('likedClubs');
      _likedClubIDs.clear();
      print('\x1B[32mLiked clubs cleared from SharedPreferences.');
      notifyListeners();
    } catch (e) {
      print('\x1B[31mError clearing liked clubs: $e');
    }
  }

  Future<void> saveLikedClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'likedClubs', _likedClubIDs.map((id) => id.toString()).toList());
  }

  Future<void> loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubIDs = prefs.getStringList('likedClubs');

    _likedClubIDs.clear();
    if (likedClubIDs != null) {
      _likedClubIDs.addAll(likedClubIDs.map((id) => int.parse(id)));
      print('\x1B[32mLiked clubs loaded from preferences.');
    } else {
      print('\x1B[32mNo liked clubs found in preferences.');
    }
  }
}
