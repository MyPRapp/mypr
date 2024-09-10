import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // For image compression

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
            // Fetch and compress club photo, save it locally
            Uint8List? photoBytes =
                await downloadAndCompressImage(club.clubPhoto, 512);
            if (photoBytes != null) {
              await _clubSaver.saveClubPhotoToFile(
                  club.clubID, photoBytes); // Save photo locally
            }

            await fetchCatalogues(club); // Fetch catalogues for the club
            _clubManager.addOrUpdateClub(club); // Save club details
          }
        }

        // Save fetched clubs and catalogues locally for offline use
        await _clubSaver.saveClubsToFile();
        await _clubSaver.saveCataloguesToFile();
      } else {
        throw Exception('Failed to load clubs: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching clubs from server, loading from local storage: $e');
      throw Exception('Failed to load clubs');
    }
  }

  // Download and compress the image, then return as Uint8List
  Future<Uint8List?> downloadAndCompressImage(
      String imageUrl, int targetWidth) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;

        // Use the image package to compress the image
        img.Image? image = img.decodeImage(imageBytes);
        if (image == null) return null;

        img.Image resizedImage =
            img.copyResize(image, width: targetWidth); // Resize image
        return Uint8List.fromList(
            img.encodeJpg(resizedImage, quality: 85)); // Compress to JPEG
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading or compressing image: $e');
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
      print('Error fetching catalogues, loading from local storage: $e');
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
      print('Error fetching club from server, loading from local storage: $e');
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
      print('Error downloading club photo, loading from local storage: $e');
      return null;
    }
  }
}
