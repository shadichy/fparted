import 'dart:io';

import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

class FileSystemSpace {
  final DataSize size;
  final DataSize used;

  const FileSystemSpace({required this.size, required this.used});

  DataSize get free => size - used;
}

abstract class FileSystemProp {
  final tmpMount = "/data/local/tmp";

  bool toolChainAvailable();

  bool canGrow();
  bool canShink();

  String? getName(Device device) => null;
  String getId(Device device);
  DataSize blockSize(Device device);
  FileSystemSpace? getSpace(Device device) => null;

  Future<ProcessResult> create(Device device);
  Future<ProcessResult> check(Device device) async {
    final mount = await Wrapper.runCmd(("mount", [device.raw, tmpMount]));
    if (mount.exitCode != 0) return mount;
    return await Wrapper.runCmd(("umount", [tmpMount]));
  }

  Future<ProcessResult> label(Device device, String label);
  Future<ProcessResult> repair(Device device);
  Future<ProcessResult>? resize(Device device, DataSize size) => null;

  ProcessResult createSync(Device device);
  ProcessResult checkSync(Device device) {
    final mount = Wrapper.runCmdSync(("mount", [device.raw, tmpMount]));
    if (mount.exitCode != 0) return mount;
    return Wrapper.runCmdSync(("umount", [tmpMount]));
  }

  ProcessResult labelSync(Device device, String label);
  ProcessResult repairSync(Device device);
  ProcessResult? resizeSync(Device device, DataSize size) => null;
}

final class OtherFS extends FileSystemProp {
  static final OtherFS _i = OtherFS._();
  OtherFS._();
  factory OtherFS() => _i;

  @override
  canGrow() => false;

  @override
  canShink() => false;

  @override
  create(_) => throw Exception("Unsupported");

  @override
  createSync(_) => throw Exception("Unsupported");

  @override
  label(_, _) => throw Exception("Unsupported");

  @override
  labelSync(_, _) => throw Exception("Unsupported");

  @override
  repair(_) => throw Exception("Unsupported");

  @override
  repairSync(_) => throw Exception("Unsupported");

  @override
  toolChainAvailable() => false;

  @override
  blockSize(_) => throw Exception("Unsupported");

  @override
  getId(_) => throw Exception("Unsupported");

  @override
  getSpace(_) => throw Exception("Unsupported");
}
