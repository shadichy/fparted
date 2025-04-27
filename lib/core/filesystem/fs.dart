import 'dart:io';

import 'package:fparted/core/model/device.dart';

enum FileSystem { fs }

extension FileSystemString on FileSystem {
  static final strMap = {};

  static FileSystem from(String string) {
    return strMap.entries.firstWhere((f) => f.key == string).value;
  }

  String get str {
    return strMap.entries.firstWhere((f) => f.value.index == index).key;
  }

  bool get isSupported {
    return false;
  }

  Future<ProcessResult> format(Device device) async {
    throw UnimplementedError();
  }
}
