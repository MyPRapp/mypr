import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubSaver {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;
  ClubSaver(this._clubs, this._catalogues, this._likedClubIDs);
  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final Directory myprDirectory = Directory('${directory.path}/mypDirectory');

    // Create the new folder if it doesn't exist
    if (await myprDirectory.exists() == false) {
      await myprDirectory.create(recursive: true);
      print('\x1B[32mFolder created: ${myprDirectory.path}');
    }

    return '${directory.path}/mypDirectory/$fileName.json';
  }

  Future<void> saveClubsToFile() async {
    String filePath = await _getFilePath('clubs');
    File file = File(filePath);

    // Save club data as JSON in local storage
    String jsonClubs = jsonEncode(_clubs.map((club) => club.toJson()).toList());
    await file.writeAsString(jsonClubs);
    print('\x1B[32mClubs saved to $filePath');
  }

  Future<void> saveCataloguesToFile() async {
    String filePath = await _getFilePath('catalogues');
    File file = File(filePath);

    // Save catalogue data as JSON in local storage
    String jsonCatalogues =
        jsonEncode(_catalogues.map((catalogue) => catalogue.toJson()).toList());
    await file.writeAsString(jsonCatalogues);
    print('\x1B[32mCatalogues saved to $filePath');
  }

  Future<void> saveClubPhotoToFile(int clubID, Uint8List photoBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/mypDirectory/club_photo_$clubID.png';

    File file = File(filePath);
    await file.writeAsBytes(photoBytes); // Save photo as binary data
    print('\x1B[32mPhoto for club ID $clubID saved at $filePath');
  }

  Future<void> saveLikedClubsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'likedClubs', _likedClubIDs.map((id) => id.toString()).toList());
  }
}
