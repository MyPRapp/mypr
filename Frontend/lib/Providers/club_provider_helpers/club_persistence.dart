import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubPersistence {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;
  // ignore: unused_field
  final VoidCallback _notifyListeners;
  ClubPersistence(
      this._clubs, this._catalogues, this._likedClubIDs, this._notifyListeners);

  // Save clubs to shared preferences
  Future<void> saveClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String clubsJson =
        jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await prefs.setString('clubs', clubsJson);
  }

  // Save catalogues to shared preferences
  Future<void> saveCataloguesToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String cataloguesJson =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await prefs.setString('catalogues', cataloguesJson);
  }

  // Save liked clubs to shared preferences
  Future<void> saveLikedClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'likedClubs', _likedClubIDs.map((id) => id.toString()).toList());
  }

  // Save image to shared preferences
  Future<void> saveImageToPreferences(String key, String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, base64Image);
  }

  // Load image from shared preferences
  Future<Image> loadImageFromPreferences(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(key);

    if (base64Image != null) {
      final Uint8List bytes = base64Decode(base64Image);
      return Image.memory(bytes);
    } else {
      throw Exception('No image found in preferences');
    }
  }
}
