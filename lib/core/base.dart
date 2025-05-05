import 'dart:convert';
import 'dart:io';

import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/model/serializable.dart';
import 'package:fparted/core/wrapper/parted/classes.dart';
import 'package:fparted/core/wrapper/parted/parted.dart';

final class Disk implements Serializable {
  final Device device;
  final DataSize size;
  final String model;
  final int logicalSectorSize;
  final int phyicalSectorSize;
  final PartitionTable? table;
  final DeviceId? uuid;
  final int maxPartition;
  final List<Partition> partitions;

  const Disk({
    required this.device,
    required this.size,
    required this.model,
    required this.logicalSectorSize,
    required this.phyicalSectorSize,
    this.table,
    this.uuid,
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

  factory Disk.fromJson(Map data) {
    final device = Device(data["path"]);
    return Disk(
      device: device,
      size: DataSize.fromString(data["size"]),
      model: data["model"],
      logicalSectorSize: data["logical-sector-size"],
      phyicalSectorSize: data["physical-sector-size"],
      uuid: DeviceId.tryParse(data["uuid"]),
      maxPartition: data["max-partitions"],
      table: PartitionTableString.from(data["label"]),
      partitions:
          (data["partitions"] as List? ?? [])
              .map((d) => Partition.fromJson(d as Map, device))
              .toList(),
    );
  }

  static Future<List<Disk>> get all async =>
      (await Parted.list).stdout
          .toString()
          .split("\n\n")
          .where((d) => d.trim().isNotEmpty)
          .map((d) => jsonDecode(d)["disk"] as Map)
          .where((d) => d["path"] != fallbackDevice().raw)
          .map(Disk.fromJson)
          .toList();

  static List<Disk> get allSync =>
      Parted.listSync.stdout
          .toString()
          .split("\n\n")
          .where((d) => d.trim().isNotEmpty)
          .map((d) => jsonDecode(d)["disk"] as Map)
          .where((d) => d["path"] != fallbackDevice().raw)
          .map(Disk.fromJson)
          .toList();

  @override
  Map<String, dynamic> toJson() => {
    "device": device,
    "size": size,
    "model": model,
    "logicalSectorSize": logicalSectorSize,
    "phyicalSectorSize": phyicalSectorSize,
    "table": table,
    "uuid": uuid,
    "maxPartition": maxPartition,
    "partitions": partitions,
  };

  @override
  String toString() => jsonEncode(
    toJson(),
    toEncodable: (e) {
      if (e is Device || e is DeviceId || e is DataSize || e is Enum) {
        return e.toString();
      }
      if (e is Serializable) {
        return e.toJson();
      }
      return e;
    },
  );
}

class OrphanPartion implements Serializable {
  final Device device;
  final DataSize size;
  final PartitionType type;
  final DeviceId? id;
  final String? name;
  final FileSystemData fileSystem;

  const OrphanPartion({
    required this.device,
    required this.size,
    required this.type,
    this.id,
    required this.name,
    required this.fileSystem,
  });

  Future<FileSystemData> format(FileSystem fs, {String? label}) async {
    throw UnimplementedError();
  }

  Future<void> edit({String? name, String? fsName}) async {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class Partition extends OrphanPartion {
  final Device diskDevice;
  final int number;
  final DataSize start;
  final DataSize end;
  final DeviceId typeId;
  final List<PartitionFlag> flags;

  static Device parseDevice(Device diskDevice, int partitionNumber) {
    final name = diskDevice.raw.split("/").last;
    if (RegExp(r"^[fhsv]d").hasMatch(name)) {
      return Device("${diskDevice.raw}$partitionNumber");
    }
    if (RegExp(r"^(nvme|mmcblk|loop|nbd)").hasMatch(name)) {
      return Device("${diskDevice.raw}p$partitionNumber");
    }
    return Device.tryParse("${diskDevice.raw}$partitionNumber") ??
        Device.tryParse("${diskDevice.raw}p$partitionNumber") ??
        diskDevice;
  }

  Partition({
    required super.size,
    required super.type,
    super.id,
    required this.typeId,
    required super.name,
    required super.fileSystem,
    required this.diskDevice,
    required this.number,
    required this.start,
    required this.end,
    Device? device,
    this.flags = const [],
  }) : super(device: device ?? parseDevice(diskDevice, number));

  factory Partition.fromJson(Map data, Device diskDevice) {
    final number = data["number"];
    final device = parseDevice(diskDevice, number);
    return Partition(
      diskDevice: diskDevice,
      number: number,
      device: device,
      size: DataSize.fromString(data["size"]),
      type: PartitionTypeString.from(data["type"]),
      id: DeviceId.fromString(data["uuid"]),
      typeId: DeviceId.tryParse(data["type-uuid"]) ?? DeviceId.fromString(data["type-id"]),
      name: data["name"],
      fileSystem: FileSystemData.fromPartition(device),
      start: DataSize.fromString(data["start"]),
      end: DataSize.fromString(data["end"]),
      flags:
          (data["flags"] as List? ?? [])
              .map((e) => PartitionFlagString.from(e))
              .toList(),
    );
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

  @override
  Map<String, dynamic> toJson() => {
    "size": size,
    "type": type,
    "id": id,
    "typeId": typeId,
    "name": name,
    "fileSystem": fileSystem,
    "diskDevice": diskDevice,
    "number": number,
    "start": start,
    "end": end,
    "device": device,
    "flags": flags,
  };

  @override
  String toString() => jsonEncode(
    toJson(),
    toEncodable: (e) {
      if (e is Device || e is DeviceId || e is DataSize || e is Enum) {
        return e.toString();
      }
      if (e is Serializable) {
        return e.toJson();
      }
      return e;
    },
  );
}
