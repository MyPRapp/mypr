import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // For compressing images
import 'package:mypr/Globals/constants.dart';
import 'package:path_provider/path_provider.dart';

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
      // Fetch the image from the URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Compress the image before saving it
        Uint8List compressedImage = await _compressImage(response.bodyBytes);

        // Get the app's cache directory to store images
        final directory = await getApplicationDocumentsDirectory();
        final Directory clubPhotosDirectory =
            Directory('${directory.path}/mypDirectory/club_photos');

        // Create the new folder if it doesn't exist
        if (await clubPhotosDirectory.exists() == false) {
          await clubPhotosDirectory.create(recursive: true);
          successPrint('Folder created: ${clubPhotosDirectory.path}');
        }

        String filePath = '${clubPhotosDirectory.path}/$fileName.jpg';

        // Write the compressed image to a file
        File file = File(filePath);
        await file.writeAsBytes(compressedImage);

        successPrint('Photo saved to file');
        return filePath;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      errorPrint('Error saving photo: $e');
      return '';
    }
  }

  Future<String> downloadAndSaveUserPhoto(String url, String fileName) async {
    try {
      // Fetch the image from the URL
      final response = await http.get(Uri.parse('http://$validatedIP$url'));

      if (response.statusCode == 200) {
        // Compress the image before saving it
        Uint8List compressedImage = await _compressImage(response.bodyBytes);

        // Get the app's cache directory to store images
        final directory = await getApplicationDocumentsDirectory();
        final Directory userPhotosDirectory =
            Directory('${directory.path}/mypDirectory/user_photos');

        // Create the new folder if it doesn't exist
        if (await userPhotosDirectory.exists() == false) {
          await userPhotosDirectory.create(recursive: true);
          successPrint('Folder created: ${userPhotosDirectory.path}');
        }
        String filePath = '${userPhotosDirectory.path}/$fileName.jpg';

        // Write the compressed image to a file
        File file = File(filePath);
        await file.writeAsBytes(compressedImage);

        successPrint('Photo saved to file');
        return filePath;
      } else {
        throw Exception('Failed to download image');
      }
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
