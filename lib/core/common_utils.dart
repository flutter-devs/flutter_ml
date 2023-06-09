import 'dart:io';

import 'package:image_picker/image_picker.dart';

class CommonUtils{

  static Future<File> convertXFileToFile(XFile xFile) async {
    final filePath = xFile.path;
    return File(filePath);
  }
}
