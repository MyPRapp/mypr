import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:http/http.dart' as http;

import '../../global_components.dart';
import '../club_provider_helpers/club_manager.dart';
import '../global_state_provider.dart';
import 'club_saver.dart';

class ClubFetcher {
  final ClubManager _clubManager;
  final ClubSaver _clubSaver;
  // ignore: unused_field
  final VoidCallback _notifyListeners;

  ClubFetcher(this._clubManager, this._clubSaver, this._notifyListeners);

  Future<void> fetchClubsAndCatalogues() async {
    print('Fetching clubs from server');
    final url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/print/';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        for (var item in data) {
          final club = ClubInfoStruct.fromJson(item);
          if (club.clubID >= 0) {
            final base64Image = await imageToBase64(club.clubPhoto);
            await _clubSaver.saveImageToPreferences(
                'club_image_${club.clubID}', base64Image);

            _clubManager.addOrUpdateClub(club);
          }
        }

        // Save clubs to shared preferences
        await _clubSaver.saveClubsToPreferences();

        // Fetch and update catalogues
        for (var club in _clubManager.allClubs) {
          await fetchCatalogues(club);
        }

        // Save catalogues to shared preferences
        await _clubSaver.saveCataloguesToPreferences();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      print('ClientException while fetching clubs: $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    } on TimeoutException catch (e) {
      print('TimeoutException while fetching clubs: $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    } catch (e) {
      print('Error fetching clubs: $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    }
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    if (club.clubID <= 0) {
      print('fetchCatalogues: Invalid club ID');
      return;
    }
    print('Fetching catalogues for \'${club.clubName}\' from server');

    final url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/${club.clubID}/catalogue';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          for (var item in data) {
            final catalogue = CatalogueInfoStruct.fromJson(item);
            _clubManager.addOrUpdateCatalogue(catalogue);

            if (catalogue.serviceType == 'Regular') {
              club.clubMinPrice =
                  (double.tryParse(catalogue.price)?.toInt() ?? 0);
              club.clubMaxPersons = catalogue.maxPersons;
              _clubManager.addOrUpdateClub(club);
            }
          }
        }
        print('Fetched catalogues for \'${club.clubName}\' from server');
      } else {
        throw Exception(
            'Failed to load catalogues for \'${club.clubName}\': ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      print(
          'ClientException while fetching catalogues for \'${club.clubName}\': $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    } on TimeoutException catch (e) {
      print(
          'TimeoutException while fetching catalogues for \'${club.clubName}\': $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    } catch (e) {
      print('Error fetching catalogues for \'${club.clubName}\': $e');
      rethrow; // Rethrow the exception to allow the calling function to handle it
    }
  }

  Future<void> fetchClub(int clubID) async {
    if (clubID <= 0) {
      print('Invalid clubID: $clubID');
      return;
    }

    print('Fetching club with clubID $clubID from server');
    final url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/print/';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // Search for the club with the given clubID
        final clubData = data.firstWhere(
          (item) => item['clubID'] == clubID,
          orElse: () => null,
        );

        if (clubData != null) {
          // Club found, process it
          final club = ClubInfoStruct.fromJson(clubData);
          final base64Image = await imageToBase64(club.clubPhoto);
          await _clubSaver.saveImageToPreferences(
              'club_image_${club.clubID}', base64Image);

          // Add or update the club in the manager
          _clubManager.addOrUpdateClub(club);

          // Save clubs to shared preferences
          await _clubSaver.saveClubsToPreferences();

          print('Club with clubID $clubID fetched and updated.');
        } else {
          print('Club with clubID $clubID not found in the server data.');
        }
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      print('ClientException while fetching club with clubID $clubID: $e');
      rethrow;
    } on TimeoutException catch (e) {
      print('TimeoutException while fetching club with clubID $clubID: $e');
      rethrow;
    } catch (e) {
      print('Error fetching club with clubID $clubID: $e');
      rethrow;
    }
  }
}
