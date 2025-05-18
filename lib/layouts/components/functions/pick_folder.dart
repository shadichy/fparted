import 'package:flutter/services.dart';

abstract final class FolderPicker {
  static const _channel = MethodChannel('vn.shadichy.parted');

  static Future<String?> pickFolder() async {
    try {
      return await _channel.invokeMethod<String>('pickFolder');
    } on PlatformException catch (e) {
      print('Error picking folder: ${e.message}');
      return null;
    }
  }
}
