import 'dart:io';

import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/su.dart';
import 'package:fparted/core/runner/wrapper.dart';

Future<String?> binaryExists(String binary) async {
  final PATH =
      "${String.fromEnvironment('PATH', defaultValue: '/bin:/system/bin')}:/data/data/vn.shadichy.parted/files/usr/bin"
          .split(":");
  if (SuBinary().initialized) {
    for (final path in PATH) {
      if (Wrapper.fileExistsSync("$path/$binary")) {
        return "$path/$binary";
      }
    }
  } else {
    for (final path in PATH) {
      if (await File("$path/$binary").exists()) {
        return "$path/$binary";
      }
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
  Job toJob(List<String> arguments);
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
        print("toolchain unavailable for '$bin'");
        continue;
      }
      _binaryMap[bin] = binPath;
    }
    _available = result;
  }

  Job create(Device device, [T? variant, String? label]);
  Job dump(Device device, [T? variant]);
  Job label(Device device, String label, [T? variant]);
  Job repair(Device device, [T? variant]);
  Job? resize(
    Device device,
    DataSize newSize, [
    T? variant,
    DataSize? blockSize,
  ]);
}
