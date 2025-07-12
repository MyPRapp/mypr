import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // For compressing images
import 'package:mypr/services/file_service.dart';
import 'package:path/path.dart' as path;

import '../Globals/global_components.dart';

class PhotoManager {
  // Private constructor
  PhotoManager._privateConstructor();

  // Static instance
  static final PhotoManager _instance = PhotoManager._privateConstructor();

  // Getter to access the instance
  static PhotoManager get instance => _instance;

  // Function to download and save the image to local storage
  Future<String> downloadAndSaveClubPhoto(String url, String fileName) async {
    if (url.isEmpty) {
      errorPrint('Club photo URL is empty');
      return '';
    }

    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to download club image: HTTP ${response.statusCode}');
      }

      // Compress image (assumed you have this function)
      Uint8List compressedImage = await _compressImage(response.bodyBytes);

      // Use FileHelper to get the photos directory
      final photosDirPath = await FileHelper.getClubPhotosDirectory();

      final filePath = path.join(photosDirPath, '$fileName.jpg');
      final file = File(filePath);

      await file.writeAsBytes(compressedImage);

      return filePath;
    } catch (e) {
      errorPrint('Error saving photo: $e');
      return '';
    }
  }

  // Helper method to compress the image to reduce its size
  Future<Uint8List> _compressImage(Uint8List imageData) async {
    // Decode the image
    img.Image? image = img.decodeImage(imageData);
    if (image == null) {
      successPrint('Invalid image format');
      throw Exception("Invalid image format");
    }

    // Resize the image to reduce size (optional)
    img.Image resizedImage =
        img.copyResize(image, width: 800); // Resize to 800px width

    // Encode the image as a JPEG with 80% quality
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));
  }
}
