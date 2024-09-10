import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubLoader {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;

  ClubLoader(this._clubs, this._catalogues, this._likedClubIDs);

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName.json';
  }

  Future<void> loadClubsFromFile() async {
    String filePath = await _getFilePath('clubs');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonClubs = await file.readAsString();
      List<dynamic> clubsList = jsonDecode(jsonClubs);

      _clubs.clear();
      _clubs.addAll(
          clubsList.map((json) => ClubInfoStruct.fromJson(json)).toList());
      print('Clubs loaded from $filePath');
    } else {
      print('Clubs file does not exist');
    }
  }

  Future<void> loadCataloguesFromFile() async {
    String filePath = await _getFilePath('catalogues');
    File file = File(filePath);

    if (await file.exists()) {
      String jsonCatalogues = await file.readAsString();
      List<dynamic> cataloguesList = jsonDecode(jsonCatalogues);

      _catalogues.clear();
      _catalogues.addAll(cataloguesList
          .map((json) => CatalogueInfoStruct.fromJson(json))
          .toList());

      print('Catalogues loaded from $filePath');
    } else {
      print('Catalogues file does not exist');
    }
  }

  Future<Uint8List?> loadClubPhotoFromFile(int clubID) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/club_photo_$clubID.png';

    File file = File(filePath);

    if (await file.exists()) {
      return await file.readAsBytes();
    } else {
      print('Photo for club ID $clubID not found');
      return null;
    }
  }

  Future<void> loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubIDs = prefs.getStringList('likedClubs');

    _likedClubIDs.clear();
    if (likedClubIDs != null) {
      _likedClubIDs.addAll(likedClubIDs.map((id) => int.parse(id)));
      print('Liked clubs loaded from preferences.');
    } else {
      print('No liked clubs found in preferences.');
    }
  }
}
