import 'dart:io';

import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';

Future<String?> binaryExists(String binary) async {
  final PATH =
      "${String.fromEnvironment('PATH', defaultValue: '/bin:/system/bin')}:/data/data/vn.shadichy.parted/files/usr/bin"
          .split(":");
  for (final path in PATH) {
    print(path);
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

abstract interface class Package {
  bool get isAvailable;
  Future<void> init();
}

abstract class RequiredPackage implements Package {
  (String, List<String>)? toCmd(List<String> arguments);
}

abstract class FilesystemPackage<T extends Enum> implements Package {
  FilesystemPackage();
  late final bool _available;
  final Map<String, String> _binaryMap = {};
  List<String> get binaries;

  @override
  get isAvailable => _available;

  Map<String, String> get binaryMap => _binaryMap;

  @override
  init() async {
    var result = true;
    for (final bin in binaries) {
      final binPath = (await binaryExists(bin));
      if (binPath == null) {
        result = false;
        continue;
      }
      _binaryMap[bin] = binPath;
    }
    _available = result;
  }

  (String, List<String>) create(Device device, [T? variant, String? label]);
  (String, List<String>) dump(Device device, [T? variant]);
  (String, List<String>) label(Device device, String label, [T? variant]);
  (String, List<String>) repair(Device device, [T? variant]);
  (String, List<String>)? resize(
    Device device,
    DataSize newSize, [
    T? variant,
    DataSize? blockSize,
  ]);
}
