import 'dart:convert';

import 'package:fparted/core/filesystem/btrfs/btrfs.dart';
import 'package:fparted/core/filesystem/extfs/extfs.dart';
import 'package:fparted/core/filesystem/f2fs/f2fs.dart';
import 'package:fparted/core/filesystem/fat/exfat.dart';
import 'package:fparted/core/filesystem/fat/vfat.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/model/serializable.dart';
import 'package:fparted/core/runner/base.dart';
import 'package:fparted/core/runner/btrfs-progs/binary.dart';
import 'package:fparted/core/runner/dosfstools/binary.dart';
import 'package:fparted/core/runner/e2fsprogs/binary.dart';
import 'package:fparted/core/runner/exfatprogs/binary.dart';
import 'package:fparted/core/runner/f2fs-tools/binary.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/wrapper.dart';

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
    String? partedFS = partedOutput["filesystem"];
    if (partedFS?.contains("swap") ?? false) partedFS = "swap";

    FileSystem type =
        partedOutput["filesystem"] == null
            ? FileSystem.none
            : FileSystem.values.firstWhere(
              (f) => f.name == partedOutput["filesystem"],
            );

    String name = "";
    DeviceId? id;
    DataSize? blockSize;
    for (final str in Wrapper.runBlkidSync(
      DeviceJob(partition, []),
    ).stdout.toString().split(" ")) {
      if (str.startsWith("UUID=")) {
        id = DeviceId.fromString(extractVar(str).$2);
      } else if (str.startsWith("LABEL=")) {
        name = extractVar(str).$2;
      } else if (str.startsWith("BLOCK_SIZE=")) {
        blockSize = DataSize.parse(extractVar(str).$2);
      } else if (str.startsWith("TYPE=") && type == FileSystem.none) {
        final fs = extractVar(str).$2.toLowerCase();
        if (fs == "vfat") {
          type = FileSystem.fat16;
        } else if (FileSystem.values.map((f) => f.name).contains(fs)) {
          type = FileSystem.values.firstWhere((f) => f.name == fs);
        }
      }
    }
    final data = OtherFS(
      partition: partition,
      type: type,
      name: name,
      id: id,
      blockSize: blockSize,
    );
    FileSystemData checker(
      FilesystemPackage packageData,
      FileSystemData Function(Device, [FileSystemData?, Map<dynamic, dynamic>])
      callback,
    ) {
      return packageData.isAvailable
          ? callback(partition, data, partedOutput)
          : data;
    }

    return switch (type) {
      FileSystem.btrfs => checker(BtrfsprogsBinary(), BtrFS.new),
      FileSystem.ext2 => checker(E2fsprogsBinary(), Ext2.new),
      FileSystem.ext3 => checker(E2fsprogsBinary(), Ext3.new),
      FileSystem.ext4 => checker(E2fsprogsBinary(), Ext4.new),
      FileSystem.f2fs => checker(F2fstoolsBinary(), F2FS.new),
      FileSystem.exfat => checker(ExfatprogsBinary(), ExFat.new),
      FileSystem.fat12 => checker(DosfstoolsBinary(), Fat12.new),
      FileSystem.fat16 => checker(DosfstoolsBinary(), Fat16.new),
      FileSystem.fat32 => checker(DosfstoolsBinary(), Fat32.new),
      _ => data,
    };
  }

  static (String, String) extractVar(String str) {
    final splitted = str.split("=");
    return (splitted.first, splitted.last.replaceAll("\"", "").trim());
  }

  bool get toolChainAvailable;

  bool get canGrow;
  bool get canShink;

  List<Job> check() => [
    Job("mount", [partition.raw, tmpMount]),
    Job("umount", [tmpMount]),
  ];

  List<Job> label(String label);
  List<Job> repair();
  List<Job?> resize(DataSize size) => [];

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
         blockSize: blockSize ?? DataSize(BigInt.from(4096)),
       );

  @override
  get canGrow => false;

  @override
  get canShink => false;

  @override
  label(_) => throw UnsupportedError("Unsupported");

  @override
  repair() => throw UnsupportedError("Unsupported");

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
  reiser4,
  reiserfs,
  xfs,
  lvm2,
  zfs,
  swap,
  squashfs,
  erofs,
  none,
}

extension FileSystemAvailability on FileSystem {
  bool get available => switch (this) {
    FileSystem.btrfs => BtrfsprogsBinary().isAvailable,
    FileSystem.ext2 => E2fsprogsBinary().isAvailable,
    FileSystem.ext3 => E2fsprogsBinary().isAvailable,
    FileSystem.ext4 => E2fsprogsBinary().isAvailable,
    FileSystem.f2fs => F2fstoolsBinary().isAvailable,
    FileSystem.exfat => ExfatprogsBinary().isAvailable,
    FileSystem.fat12 => DosfstoolsBinary().isAvailable,
    FileSystem.fat16 => DosfstoolsBinary().isAvailable,
    FileSystem.fat32 => DosfstoolsBinary().isAvailable,
    FileSystem.none => true,
    _ => false,
  };

  static List<FileSystem> get availableTypes {
    return FileSystem.values.where((f) => f.available).toList();
  }

  FilesystemPackage get toolchain => switch (this) {
    FileSystem.btrfs => BtrfsprogsBinary(),
    FileSystem.ext2 => E2fsprogsBinary(),
    FileSystem.ext3 => E2fsprogsBinary(),
    FileSystem.ext4 => E2fsprogsBinary(),
    FileSystem.f2fs => F2fstoolsBinary(),
    FileSystem.exfat => ExfatprogsBinary(),
    FileSystem.fat12 => DosfstoolsBinary(),
    FileSystem.fat16 => DosfstoolsBinary(),
    FileSystem.fat32 => DosfstoolsBinary(),
    _ => throw Exception("Toolchain for '$name' is not available"),
  };
}
