import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CredentialController {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/userCredentials.txt');
  }

  static Future<File> writeFile( String data ) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(data);
  }

  static Future<String> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      throw e;
    }
  }

  static Future<File> clearFile() async {
    final file = await _localFile;

    return file.writeAsString("");
  }
}