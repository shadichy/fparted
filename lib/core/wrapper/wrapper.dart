import 'dart:io';

import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/blkid/binary.dart';
import 'package:fparted/core/wrapper/btrfs-progs/binary.dart';
import 'package:fparted/core/wrapper/dosfstools/binary.dart';
import 'package:fparted/core/wrapper/e2fsprogs/binary.dart';
import 'package:fparted/core/wrapper/exfatprogs/binary.dart';
import 'package:fparted/core/wrapper/f2fs-tools/binary.dart';
import 'package:fparted/core/wrapper/parted/binary.dart';
import 'package:fparted/core/wrapper/su.dart';

abstract final class Wrapper {
  static Future<ProcessResult> runCmd(
    (String command, List<String> arguments) cmd,
  ) async {
    final su = SuBinary().toCmd([cmd.$1, ...cmd.$2]);
    return Process.run(su.$1, su.$2);
  }

  static ProcessResult runCmdSync(
    (String command, List<String> arguments) cmd,
  ) {
    final su = SuBinary().toCmd([cmd.$1, ...cmd.$2]);
    return Process.runSync(su.$1, su.$2);
  }

  static Future<bool> fileExists(String path) async {
    return (await runCmd(("test", ["-e", path]))).exitCode == 0;
  }

  static bool fileExistsSync(String path) {
    return runCmdSync(("test", ["-e", path])).exitCode == 0;
  }

  static Future<ProcessResult> runParted(
    (Device device, List<String> arguments) cmd,
  ) async {
    return runCmd(PartedBinary().toCmd([cmd.$1.raw, ...cmd.$2]));
  }

  static ProcessResult runPartedSync(
    (Device device, List<String> arguments) cmd,
  ) {
    return runCmdSync(PartedBinary().toCmd([cmd.$1.raw, ...cmd.$2]));
  }

  static Future<ProcessResult> runBlkid(
    (Device device, List<String> arguments) cmd,
  ) async {
    return runCmd(BlkidBinary().toCmd([cmd.$1.raw, ...cmd.$2]));
  }

  static ProcessResult runBlkidSync(
    (Device device, List<String> arguments) cmd,
  ) {
    return runCmdSync(BlkidBinary().toCmd([cmd.$1.raw, ...cmd.$2]));
  }

  static Future<void> init() async {
    await SuBinary().init();
    await deviceInit();
    await PartedBinary().init();
    await BlkidBinary().init();
    await BtrfsprogsBinary().init();
    await DosfstoolsBinary().init();
    await E2fsprogsBinary().init();
    await ExfatprogsBinary().init();
    await F2fstoolsBinary().init();
  }
}
