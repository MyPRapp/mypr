import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static String? _basePath;

  static Future<String> getBasePath() async {
    if (_basePath == null) {
      final directory = await getApplicationDocumentsDirectory();
      final myprDirectory = Directory('${directory.path}/mypDirectory');

      if (!(await myprDirectory.exists())) {
        await myprDirectory.create(recursive: true);
      }

      _basePath = myprDirectory.path;
    }
    return _basePath!;
  }

  static Future<String> getFilePath(String fileName) async {
    final base = await getBasePath();
    return '$base/$fileName.json';
  }

  // Helper method for photos folder
  static Future<String> getClubPhotosDirectory() async {
    final base = await getBasePath();
    final photosDir = Directory(path.join(base, 'club_photos'));
    if (!(await photosDir.exists())) {
      await photosDir.create(recursive: true);
    }
    return photosDir.path;
  }
}
