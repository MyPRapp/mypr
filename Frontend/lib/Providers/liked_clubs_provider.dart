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
      print('✅Liked clubs cleared from SharedPreferences.');
      notifyListeners();
    } catch (e) {
      print('❌Error clearing liked clubs: $e');
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
      print('✅Liked clubs loaded from preferences.');
    } else {
      print('✅No liked clubs found in preferences.');
    }
  }
}
