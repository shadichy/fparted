import 'dart:io';

import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/blkid/binary.dart';
import 'package:fparted/core/runner/btrfs-progs/binary.dart';
import 'package:fparted/core/runner/dd/binarry.dart';
import 'package:fparted/core/runner/dosfstools/binary.dart';
import 'package:fparted/core/runner/e2fsprogs/binary.dart';
import 'package:fparted/core/runner/exfatprogs/binary.dart';
import 'package:fparted/core/runner/f2fs-tools/binary.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/binary.dart';
import 'package:fparted/core/runner/su.dart';

abstract final class Wrapper {
  static Job _toRunJob(Job cmd) {
    return SuBinary().toJob([cmd.command, ...cmd.arguments]);
  }

  static Future<ProcessResult> runJob(Job cmd) async {
    final su = _toRunJob(cmd);
    return Process.run(su.command, su.arguments);
  }

  static ProcessResult runJobSync(Job cmd) {
    final su = _toRunJob(cmd);
    return Process.runSync(su.command, su.arguments);
  }

  static Future<bool> fileExists(String path) async {
    return (await runJob(Job("test", ["-e", path]))).exitCode == 0;
  }

  static bool fileExistsSync(String path) {
    return runJobSync(Job("test", ["-e", path])).exitCode == 0;
  }

  static Future<ProcessResult> runParted(DeviceJob cmd) async {
    return runJob(PartedBinary().toJob(cmd));
  }

  static ProcessResult runPartedSync(DeviceJob cmd) {
    return runJobSync(PartedBinary().toJob(cmd));
  }

  static Future<ProcessResult> runBlkid(DeviceJob cmd) async {
    return runJob(BlkidBinary().toJob(cmd));
  }

  static ProcessResult runBlkidSync(DeviceJob cmd) {
    return runJobSync(BlkidBinary().toJob(cmd));
  }

  static Future<void> init() async {
    await SuBinary().init();
    await deviceInit();
    await PartedBinary().init();
    await BlkidBinary().init();
    await DDBinary().init();
    await BtrfsprogsBinary().init();
    await DosfstoolsBinary().init();
    await E2fsprogsBinary().init();
    await ExfatprogsBinary().init();
    await F2fstoolsBinary().init();
  }
}
