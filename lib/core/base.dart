import 'dart:convert';
import 'dart:io';

import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/parted/classes.dart';
import 'package:fparted/core/wrapper/parted/parted.dart';

abstract interface class Serializable {
  Map get toJson;
}

class Disk {
  final Device device;
  final DataSize size;
  final String model;
  final int logicalSectorSize;
  final int phyicalSectorSize;
  final PartitionTable? table;
  final DeviceId uuid;
  final int maxPartition;
  final List<Partition> partitions;

  const Disk({
    required this.device,
    required this.size,
    required this.model,
    required this.logicalSectorSize,
    required this.phyicalSectorSize,
    this.table,
    required this.uuid,
    required this.maxPartition,
    this.partitions = const [],
  });

  Parted get parted => Parted(this);

  Future<Partition> create({
    required DataSize start,
    required DataSize end,
    PartitionType type = PartitionType.PRIMARY,
    String? partitionLabel,
    FileSystem? fileSystem,
    String? fileSystemLabel,
  }) async {
    // parted.createPart(start, end, type);
    // TODO:
    throw UnimplementedError();
  }

  Future<ProcessResult> createTable(PartitionTable table) async {
    return await parted.createTable(table);
  }

  factory Disk.fromJSON(Map data) {
    return Disk(
      device: Device(data["device"]),
      size: DataSize.fromString(data["size"]),
      model: data["model"],
      logicalSectorSize: data["logical_sector_size"],
      phyicalSectorSize: data["phyical_sector_size"],
      uuid: DeviceId.fromString(data["uuid"]),
      maxPartition: data["max_partition"],
      partitions:
          data["partitions"] == null
              ? []
              : (data["partitions"] as Iterable<Map>)
                  .map(Partition.fromJSON)
                  .toList(),
    );
  }

  static Future<List<Disk>> get all async =>
      (await Parted.list).stdout
          .toString()
          .split("\n\n")
          .map((s) => Disk.fromJSON(jsonDecode(s)))
          .toList();
}

class OrphanPartion {
  final Device device;
  final DataSize size;
  final PartitionType type;
  final DeviceId id;
  final String? name;
  final FileSystemData? fileSystem;

  const OrphanPartion({
    required this.device,
    required this.size,
    required this.type,
    required this.id,
    required this.name,
    required this.fileSystem,
  });

  Future<FileSystemData> format(FileSystem fs, {String? label}) async {
    throw UnimplementedError();
  }

  Future<void> edit({String? name, String? fsName}) async {
    throw UnimplementedError();
  }
}

class Partition extends OrphanPartion {
  final Disk disk;
  final int number;
  final DataSize start;
  final DataSize end;
  final DeviceId typeId;
  final List<PartitionFlag> flags;

  Partition({
    required super.size,
    required super.type,
    required super.id,
    required this.typeId,
    required super.name,
    required super.fileSystem,
    required this.disk,
    required this.number,
    required this.start,
    required this.end,
    this.flags = const [],
  }) : super(device: parseDevice(disk, number));

  static Device parseDevice(Disk disk, int partitionNumber) {
    throw UnimplementedError();
  }

  PartedPartitionOperation get parted => PartedPartitionOperation.from(this);

  @override
  Future<void> edit({
    String? name,
    DataSize? start,
    DataSize? end,
    DeviceId? typeId,
    List<PartitionFlag> flags = const [],
    String? fsName,
  }) async {
    throw UnimplementedError();
  }

  Future<void> delete() async {
    // You cannot delete Orphaned partitions (loop devices)
    throw UnimplementedError();
  }

  factory Partition.fromJSON(Map data) {
    throw UnimplementedError();
    // data from parted
    // data from blkid
    // data from filesystem-specific
  }
}
