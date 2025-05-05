import 'dart:convert';
import 'dart:io';

import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/model/serializable.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

final class FileSystemSpace implements Serializable {
  final DataSize size;
  final DataSize used;
  final DataSize free;

  FileSystemSpace.size_used({required this.size, required this.used})
    : free = size - used;
  FileSystemSpace.size_free({required this.size, required this.free})
    : used = size - free;
  FileSystemSpace.free_used({required this.free, required this.used})
    : size = free + used;

  @override
  Map<String, dynamic> toJson() => {
    "size": size.toString(),
    "used": used.toString(),
    "free": free.toString(),
  };

  @override
  String toString() => jsonEncode(toJson());
}

abstract class FileSystemData implements Serializable {
  static final tmpMount = "/data/local/tmp";
  final Device partition;
  final FileSystem type;
  final String name;
  final DeviceId id;
  final FileSystemSpace? space;
  final DataSize blockSize;

  const FileSystemData({
    required this.partition,
    required this.type,
    required this.name,
    required this.id,
    this.space,
    required this.blockSize,
  });

  factory FileSystemData.fromPartition(
    Device partition, [
    Map partedOutput = const {},
  ]) {
    FileSystem type = FileSystem.none;
    String name = "";
    DeviceId id = DeviceId(0);
    DataSize blockSize = DataSize(BigInt.zero);
    for (final str in Wrapper.runBlkidSync((
      partition,
      [],
    )).stdout.toString().split(" ")) {
      if (str.startsWith("UUID=")) {
        id = DeviceId.fromString(extractVar(str).$2);
      } else if (str.startsWith("LABEL=")) {
        name = extractVar(str).$2;
      } else if (str.startsWith("TYPE=")) {
        final fs = extractVar(str).$2.toLowerCase();
        if (FileSystem.values.map((f) => f.name).contains(fs)) {
          type = FileSystem.values.firstWhere((f) => f.name == fs);
        }
      } else if (str.startsWith("BLOCK_SIZE=")) {
        blockSize = DataSize.parse(extractVar(str).$2);
      }
    }
    return OtherFS(
      partition: partition,
      type: type,
      name: name,
      id: id,
      blockSize: blockSize,
    );
  }

  static (String, String) extractVar(String str) {
    final splitted = str.split("=");
    return (splitted.first, splitted.last.replaceAll("\"", ""));
  }

  bool get toolChainAvailable;

  bool get canGrow;
  bool get canShink;

  Future<ProcessResult> check() async {
    final mount = await Wrapper.runCmd(("mount", [partition.raw, tmpMount]));
    if (mount.exitCode != 0) return mount;
    return await Wrapper.runCmd(("umount", [tmpMount]));
  }

  Future<ProcessResult> label(String label);
  Future<ProcessResult> repair();
  Future<ProcessResult>? resize(DataSize size) => null;

  ProcessResult checkSync() {
    final mount = Wrapper.runCmdSync(("mount", [partition.raw, tmpMount]));
    if (mount.exitCode != 0) return mount;
    return Wrapper.runCmdSync(("umount", [tmpMount]));
  }

  ProcessResult labelSync(String label);
  ProcessResult repairSync();
  ProcessResult? resizeSync(DataSize size) => null;

  @override
  Map<String, dynamic> toJson() => {
    "partition": partition,
    "type": type,
    "name": name,
    "id": id,
    "space": space,
    "blockSize": blockSize,
  };
  @override
  String toString() => jsonEncode(
    toJson(),
    toEncodable: (e) {
      if (e is Device || e is DataSize || e is Enum) {
        return e.toString();
      }
      if (e is Serializable) {
        return e.toJson();
      }
      return e;
    },
  );
}

final class OtherFS extends FileSystemData {
  OtherFS({
    required super.partition,
    super.type = FileSystem.none,
    super.name = "",
    DeviceId? id,
    DataSize? blockSize,
  }) : super(
         id: id ?? DeviceId(0),
         blockSize: blockSize ?? DataSize(BigInt.zero),
       );

  @override
  get canGrow => false;

  @override
  get canShink => false;

  @override
  label(_) => throw UnsupportedError("Unsupported");

  @override
  labelSync(_) => throw UnsupportedError("Unsupported");

  @override
  repair() => throw UnsupportedError("Unsupported");

  @override
  repairSync() => throw UnsupportedError("Unsupported");

  @override
  get toolChainAvailable => false;
}

enum FileSystem {
  affs,
  apfs,
  bcachefs,
  btrfs,
  exfat,
  ext2,
  ext3,
  ext4,
  f2fs,
  fat12,
  fat16,
  fat32,
  hfs,
  hfs_plus,
  jfs,
  ntfs,
  reiserfs,
  xfs,
  lvm2,
  zfs,
  squashfs,
  erofs,
  none,
}
