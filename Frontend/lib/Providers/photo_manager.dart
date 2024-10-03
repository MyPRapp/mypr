import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img; // For compressing images
import 'package:path_provider/path_provider.dart';

class PhotoManager {
  // Function to download and save the image to local storage
  Future<String> downloadAndSavePhoto(String url, String fileName) async {
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
          print('\x1B[32mFolder created: ${clubPhotosDirectory.path}');
        }

        String filePath = '${clubPhotosDirectory.path}/$fileName.jpg';

        // Write the compressed image to a file
        File file = File(filePath);
        await file.writeAsBytes(compressedImage);

        print('\x1B[32mPhoto saved to $filePath');
        return filePath;
      } else {
        throw Exception('Failed to download image');
      }
    } catch (e) {
      print('\x1B[31mError saving photo: $e');
      return '';
    }
  }

  // Helper method to compress the image to reduce its size
  Future<Uint8List> _compressImage(Uint8List imageData) async {
    // Decode the image
    img.Image? image = img.decodeImage(imageData);
    if (image == null) {
      print('\x1B[32mInvalid image format');
      throw Exception("Invalid image format");
    }

    // Resize the image to reduce size (optional)
    img.Image resizedImage =
        img.copyResize(image, width: 800); // Resize to 800px width

    // Encode the image as a JPEG with 80% quality
    return Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));
  }
}
