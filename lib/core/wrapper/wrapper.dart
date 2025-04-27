import 'dart:io';

import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/parted/binary.dart';
import 'package:fparted/core/wrapper/su.dart';

abstract final class Wrapper {
  static Future<ProcessResult> runCmd(
    (String command, List<String> arguments) cmd,
  ) async {
    final su = SuBinary().toCmd([cmd.$1, ...cmd.$2]);
    return Process.run(su.$1, su.$2);
  }

  static Future<ProcessResult> runParted(
    (Device device, List<String> arguments) cmd,
  ) async {
    return runCmd(PartedBinary().toCmd([cmd.$1.raw, ...cmd.$2]));
  }
}
