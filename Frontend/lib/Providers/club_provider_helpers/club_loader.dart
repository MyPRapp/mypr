import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubLoader {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;
  // ignore: unused_field
  final VoidCallback _notifyListeners;

  ClubLoader(
      this._clubs, this._catalogues, this._likedClubIDs, this._notifyListeners);

  Future<void> loadClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? clubsJson = prefs.getString('clubs');
    final String? cataloguesJson = prefs.getString('catalogues');

    if (clubsJson != null && cataloguesJson != null) {
      try {
        print('Loading clubs from preferences');
        final List<dynamic> clubsList = jsonDecode(clubsJson);
        final List<dynamic> cataloguesList = jsonDecode(cataloguesJson);

        _clubs.clear();
        _catalogues.clear();

        for (var catalogue in cataloguesList) {
          _catalogues.add(CatalogueInfoStruct.fromJson(catalogue));
        }

        for (var club in clubsList) {
          ClubInfoStruct clubStruct = ClubInfoStruct.fromJson(club);

          // Update clubMinPrice and clubMaxPersons using the catalogues
          final regularCatalogue = _catalogues.firstWhere(
            (catalogue) =>
                catalogue.clubID == clubStruct.clubID &&
                catalogue.serviceType == 'Regular',
            orElse: () => CatalogueInfoStruct(
              clubID: clubStruct.clubID,
              serviceType: 'Regular',
              price: '0',
              maxPersons: 0,
            ),
          );

          clubStruct.clubMinPrice =
              (double.parse(regularCatalogue.price)).toInt();
          clubStruct.clubMaxPersons = regularCatalogue.maxPersons;

          _clubs.add(clubStruct);
          print(
              'Loaded club: ${clubStruct.clubName} with ID: ${clubStruct.clubID}');
        }
      } catch (e) {
        print('Error loading clubs from preferences: $e');
      }
    } else {
      print('No clubs or catalogues found in preferences');
    }
  }

  Future<void> loadCataloguesFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cataloguesJson = prefs.getString('catalogues');
    if (cataloguesJson != null) {
      try {
        print('Loading catalogues from preferences');
        final List<dynamic> cataloguesList = jsonDecode(cataloguesJson);

        _catalogues.clear();
        for (var catalogue in cataloguesList) {
          _catalogues.add(CatalogueInfoStruct.fromJson(catalogue));
          print('Loaded catalogue for club ID: ${catalogue.clubID}');
        }
      } catch (e) {
        print('Error loading catalogues from preferences: $e');
      }
    } else {
      print('No catalogues found in preferences');
    }
  }

  Future<void> loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubsStringList = prefs.getStringList('likedClubs');

    if (likedClubsStringList != null) {
      print('Loading liked clubs from preferences');
      _likedClubIDs.clear();
      _likedClubIDs.addAll(likedClubsStringList.map((id) => int.parse(id)));
      print('Loaded liked clubs: $_likedClubIDs');
    } else {
      print('No liked clubs found in preferences');
    }
  }
}
