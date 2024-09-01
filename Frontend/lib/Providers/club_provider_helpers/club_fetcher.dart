import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

import '../../global_components.dart';
import '../club_provider_helpers/club_manager.dart';
import '../global_state_provider.dart';
import 'club_persistence.dart';

class ClubFetcher {
  final ClubManager _clubManager;
  final ClubPersistence _clubPersistence;
  // ignore: unused_field
  final VoidCallback _notifyListeners;
  ClubFetcher(this._clubManager, this._clubPersistence, this._notifyListeners);

  Future<void> fetchClubsAndCatalogues() async {
    final url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/print/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
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
      // Handle the error more gracefully, possibly by notifying the UI
      print('Error fetching clubs: $e');
      // Optionally rethrow or handle the error in a way that doesn't crash the app
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

    final url =
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
              club.clubMinPrice = int.tryParse(catalogue.price) ?? 0;
              club.clubMaxPersons = catalogue.maxPersons;
              _clubManager.addOrUpdateClub(club);
            }
          }
        }
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching catalogues: $e');
      // Handle or rethrow the exception if needed
    }
  }
}
