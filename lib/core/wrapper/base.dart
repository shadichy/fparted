import 'dart:io';

import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';

Future<String?> binaryExists(String binary) async {
  for (final path
      in "/data/data/vn.shadichy.fparted/files/usr/bin:${String.fromEnvironment('PATH', defaultValue: '/system/bin')}"
          .split(":")) {
    if (await File("$path/$binary").exists()) {
      return "$path/$binary";
    }
  }
  return null;
}

String argToArg(Iterable<String>? arguments) =>
    arguments
        ?.map((e) => e.replaceAll("\\", "\\\\").replaceAll(" ", "\\ "))
        .join(" ") ??
    "";

abstract class Package {
  bool isAvailable();
  Future<void> init();
  (String, List<String>)? toCmd(List<String> arguments);
}

abstract class FilesystemPackage<T extends Enum> extends Package {
  @override
  toCmd(_) => null;

  (String, List<String>) create(Device device, [T? variant]);
  (String, List<String>) label(Device device, String label, [T? variant]);
  (String, List<String>) fix(Device device, [T? variant]);
  (String, List<String>)? resize(
    Device device,
    DataSize newSize, [
    T? variant,
    DataSize? blockSize,
  ]);
}
