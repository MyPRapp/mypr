import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../global_components.dart';
import '../club_provider_helpers/club_manager.dart';
import '../global_state_provider.dart';
import 'club_persistence.dart';

class ClubFetcher {
  final ClubManager _clubManager;
  final ClubPersistence _clubPersistence;

  ClubFetcher(this._clubManager, this._clubPersistence);

  Future<void> fetchClubsAndCatalogues() async {
    var url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/print/';
    try {
      final response = await http.get(Uri.parse(url));
      final decodedBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(decodedBody);

        for (var item in data) {
          final club = ClubInfoStruct.fromJson(item);
          if (club.clubID >= 0) {
            final base64Image = await imageToBase64(club.clubPhoto);
            await _clubPersistence.saveImageToPreferences(
                'club_image_${club.clubID}', base64Image);
            _clubManager.addOrUpdateClub(club);
          }
        }

        // Save clubs to shared preferences
        await _clubPersistence.saveClubsToPreferences();

        // Fetch and update catalogues
        await fetchAndSaveCatalogues();

        // Save catalogues to shared preferences
        await _clubPersistence.saveCataloguesToPreferences();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
    }
  }

  Future<void> fetchAndSaveCatalogues() async {
    for (var club in _clubManager.allClubs) {
      await fetchCatalogues(club);
    }
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    if (club.clubID <= 0) {
      print('fetchCatalogues: Invalid club ID');
      return;
    }

    String url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/${club.clubID}/catalogue';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          for (var item in data) {
            final catalogue = CatalogueInfoStruct.fromJson(item);
            _clubManager.addOrUpdateCatalogue(catalogue);

            if (catalogue.serviceType == 'Regular') {
              club.clubMinPrice = double.parse(catalogue.price).toInt();
              club.clubMaxPersons = catalogue.maxPersons;
              _clubManager.addOrUpdateClub(club);
            }
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching catalogues: $e');
    }
  }
}
