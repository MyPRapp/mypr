import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubSaver {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;
  // ignore: unused_field
  final VoidCallback _notifyListeners;

  ClubSaver(
      this._clubs, this._catalogues, this._likedClubIDs, this._notifyListeners);

  // Save clubs to shared preferences
  Future<void> saveClubsToPreferences() async {
    print('Saving clubs to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String clubsJson =
        jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await prefs.setString('clubs', clubsJson);
    print('Saved clubs to preferences');
    // Save each club's photo individually
    for (var club in _clubs) {
      if (club.clubPhoto.isNotEmpty) {
        // Saving club photo using clubID as a unique key
        await saveClubPhotoToPreferences(club.clubID, club.clubPhoto);
      }
    }
  }

  // Save catalogues to shared preferences
  Future<void> saveCataloguesToPreferences() async {
    print('Saving catalogues to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cataloguesJson =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await prefs.setString('catalogues', cataloguesJson);
    print('Saved catalogues to preferences');
  }

  // Save liked clubs to shared preferences
  Future<void> saveLikedClubsToPreferences() async {
    print('Saving liked clubs to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'likedClubs', _likedClubIDs.map((id) => id.toString()).toList());
    print('Saved liked clubs to preferences');
  }

  // Save individual club photo to shared preferences
  Future<void> saveClubPhotoToPreferences(
      int clubID, String base64Photo) async {
    print('Saving photo for club ID $clubID to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('club_photo_$clubID', base64Photo);
    print('Saved photo for club ID $clubID to preferences');
  }
}
