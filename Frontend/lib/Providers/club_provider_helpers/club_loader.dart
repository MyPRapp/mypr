import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../global_components.dart';

class ClubLoader {
  final List<ClubInfoStruct> _clubs;
  final List<CatalogueInfoStruct> _catalogues;
  final List<int> _likedClubIDs;

  ClubLoader(this._clubs, this._catalogues, this._likedClubIDs);

  Future<void> loadClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? clubsJson = prefs.getString('clubs');
    final String? cataloguesJson = prefs.getString('catalogues');

    if (clubsJson != null && cataloguesJson != null) {
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

        clubStruct.clubMinPrice = double.parse(regularCatalogue.price).toInt();
        clubStruct.clubMaxPersons = regularCatalogue.maxPersons;

        _clubs.add(clubStruct);
      }
    }
  }

  Future<void> loadCataloguesFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cataloguesJson = prefs.getString('catalogues');
    if (cataloguesJson != null) {
      final List<dynamic> cataloguesList = jsonDecode(cataloguesJson);
      _catalogues.clear();
      for (var catalogue in cataloguesList) {
        _catalogues.add(CatalogueInfoStruct.fromJson(catalogue));
      }
    }
  }

  Future<void> loadLikedClubsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedClubsStringList = prefs.getStringList('likedClubs');

    if (likedClubsStringList != null) {
      _likedClubIDs.clear();
      _likedClubIDs.addAll(likedClubsStringList.map((id) => int.parse(id)));
    }
  }
}
