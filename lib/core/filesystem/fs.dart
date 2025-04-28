import 'dart:io';

import 'package:fparted/core/filesystem/base.dart';
import 'package:fparted/core/filesystem/btrfs/btrfs.dart';
import 'package:fparted/core/filesystem/extfs/extfs.dart';
import 'package:fparted/core/filesystem/f2fs/f2fs.dart';
import 'package:fparted/core/filesystem/fat/exfat.dart';
import 'package:fparted/core/filesystem/fat/vfat.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';

class FileSystemData {
  final FileSystem type;
  final String name;
  final DeviceId id;
  final FileSystemSpace space;
  final DataSize blockSize;

  const FileSystemData({
    required this.type,
    required this.name,
    required this.id,
    required this.space,
    required this.blockSize,
  });
}

enum FileSystem {
  affs,
  apfs,
  bcachefs,
  btrfs,
  dosfs,
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

extension FileSystemString on FileSystem {
  static FileSystem from(String string) {
    return FileSystem.values.firstWhere((f) => f.name == string);
  }

  FileSystemProp get prop => switch (this) {
    FileSystem.dosfs => Msdos(),
    FileSystem.fat12 => Fat12(),
    FileSystem.fat16 => Fat16(),
    FileSystem.fat32 => Fat32(),
    FileSystem.exfat => ExFat(),
    FileSystem.ext2 => Ext2(),
    FileSystem.ext3 => Ext3(),
    FileSystem.ext4 => Ext4(),
    FileSystem.btrfs => BtrFS(),
    FileSystem.f2fs => F2FS(),
    _ => OtherFS(),
  };

  String get str => name;

  bool get isSupported => prop.toolChainAvailable();

  Future<ProcessResult> create(Device device) => prop.create(device);
  Future<ProcessResult> check(Device device) => prop.check(device);
  Future<ProcessResult> label(Device device, String label) =>
      prop.label(device, label);
  Future<ProcessResult> repair(Device device) => prop.repair(device);
  Future<ProcessResult>? resize(Device device, DataSize size) =>
      prop.resize(device, size);

  ProcessResult createSync(Device device) => prop.createSync(device);
  ProcessResult checkSync(Device device) => prop.checkSync(device);
  ProcessResult labelSync(Device device, String label) =>
      prop.labelSync(device, label);
  ProcessResult repairSync(Device device) => prop.repairSync(device);
  ProcessResult? resizeSync(Device device, DataSize size) =>
      prop.resizeSync(device, size);
}
