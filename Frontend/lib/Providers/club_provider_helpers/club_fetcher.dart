import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../global_components.dart';
import '../club_provider_helpers/club_manager.dart';
import '../global_state_provider.dart';
import 'club_saver.dart';

class ClubFetcher {
  final ClubManager _clubManager;
  final ClubSaver _clubSaver;

  ClubFetcher(this._clubManager, this._clubSaver);

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
            // Download club photo and save it to the device directory
            Uint8List? photoBytes = await downloadClubPhoto(club.clubPhoto);
            if (photoBytes != null) {
              await _clubSaver.saveClubPhotoToFile(club.clubID, photoBytes);
            }

            fetchCatalogues(club);

            // Add or update club in the manager
            _clubManager.addOrUpdateClub(club);
          }
        }

        // Save clubs and catalogues to file (excluding photos)
        await _clubSaver.saveClubsToFile();
        await _clubSaver.saveCataloguesToFile();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs: $e');
      rethrow;
    }
  }

  // Download club photo as Uint8List
  Future<Uint8List?> downloadClubPhoto(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes; // Return photo as binary data
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading club photo: $e');
      return null;
    }
  }

  Future<void> fetchCatalogues(ClubInfoStruct club) async {
    if (club.clubID <= 0) {
      print('Invalid club ID');
      return;
    }

    print('Fetching catalogues for ${club.clubName} from server');
    final url =
        'http://${GlobalStateProvider().validatedIp}:8000/api/clubs/${club.clubID}/catalogue';
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
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
        print('Fetched catalogues for ${club.clubName}');
      } else {
        throw Exception('Failed to load catalogues: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching catalogues for ${club.clubName}: $e');
      rethrow;
    }
  }

  Future<void> fetchClub(int clubID) async {
    if (clubID <= 0) {
      print('Invalid club ID');
      return;
    }

    print('Fetching club with ID $clubID from server');
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
          final club = ClubInfoStruct.fromJson(clubData);

          // Download club photo and save it to the device directory
          Uint8List? photoBytes = await downloadClubPhoto(club.clubPhoto);
          if (photoBytes != null) {
            await _clubSaver.saveClubPhotoToFile(club.clubID, photoBytes);
          }

          _clubManager.addOrUpdateClub(club);
          await _clubSaver.saveClubsToFile();
          print('Club with ID $clubID fetched and updated.');
        } else {
          print('Club with ID $clubID not found');
        }
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching club with ID $clubID: $e');
      rethrow;
    }
  }
}
