import 'package:flutter/cupertino.dart';
import 'package:mypr/Globals/global_components.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Globals/classes.dart';

class LikedClubsProvider extends ChangeNotifier {
  final List<int> _likedClubs = []; //Contains id's of clubs

  Future<void> toggleLike(int clubID) async {
    if (_likedClubs.contains(clubID)) {
      _likedClubs.remove(clubID);
    } else {
      _likedClubs.add(clubID);
    }

    await saveLikedClubsToPreferences();
    notifyListeners();
  }

  Future<void> deleteAllLiked() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('likedClubs');
      _likedClubs.clear();
      successPrint('Liked clubs cleared from SharedPreferences.');

      notifyListeners();
    } catch (e) {
      errorPrint('Error clearing liked clubs: $e');
    }
  }

  Future<void> loadLikedClubsFromPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? likedClubIDsFromPreferences =
          prefs.getStringList('likedClubs');

      _likedClubs.clear();

      if (likedClubIDsFromPreferences != null) {
        _likedClubs
            .addAll(likedClubIDsFromPreferences.map((id) => int.parse(id)));
        successPrint('Liked clubs loaded from preferences.');
      } else {
        successPrint('No liked clubs found in preferences.');
      }
    } catch (e) {
      errorPrint('Error loading liked clubs: $e');
    }
  }

  Future<void> saveLikedClubsToPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'likedClubs', _likedClubs.map((id) => id.toString()).toList());
      print("Liked clubs saved successfully.");
    } catch (e) {
      print("Error saving liked clubs: $e");
    }
  }

  List<ClubInfoStruct> getAllLikedClubs(List<ClubInfoStruct> clubs) {
    return clubs.where((club) => _likedClubs.contains(club.clubID)).toList();
  }

  bool isLiked(int clubID) {
    return _likedClubs.contains(clubID);
  }
}
