import 'package:fparted/core/base.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/classes.dart';

class Parted {
  final Disk disk;
  const Parted(this.disk);

  PartedPartitionOperation partition(int number) {
    return PartedPartitionOperation(
      diskDevice: disk.device,
      partitionNumber: number,
    );
  }

  static List<PartedJob> get list => [
    PartedJob(fallbackDevice(), ["print", "all"]),
  ];

  List<PartedJob> flag(DiskFlag flag, bool enable) => [
    PartedJob(disk.device, ["disk_set", enable ? "on" : "off"]),
  ];

  List<PartedJob> createTable(PartitionTable table) => [
    PartedJob(disk.device, ["mklabel", table.str]),
  ];

  List<PartedJob> createPart(
    DataSize start,
    DataSize end,
    PartitionType type, [
    PartitionFileSystem? filesystem,
  ]) => [
    PartedJob(disk.device, [
      "mkpart",
      type.str,
      ...(filesystem == null ? [] : [filesystem.str]),
      start.byte.toStringAsFixed(2),
      end.byte.toStringAsFixed(2),
    ]),
  ];
}

class PartedPartitionOperation {
  final Device diskDevice;
  final int partitionNumber;

  const PartedPartitionOperation({
    required this.diskDevice,
    required this.partitionNumber,
  });
  factory PartedPartitionOperation.from(Partition partition) {
    return PartedPartitionOperation(
      diskDevice: partition.diskDevice,
      partitionNumber: partition.number,
    );
  }

  List<PartedJob> flag(PartitionFlag flag, bool enable) => [
    PartedJob(diskDevice, [
      "set",
      "$partitionNumber",
      flag.str,
      enable ? "on" : "off",
    ]),
  ];

  List<PartedJob> label(String name) => [
    PartedJob(diskDevice, ["name", "$partitionNumber", name]),
  ];

  List<PartedJob> setTypeId(DeviceId id) => [
    PartedJob(
      diskDevice,
      ["type", "$partitionNumber"],
      //do something with id
    ),
  ];

  List<PartedJob> resize(DataSize size) => [PartedJob(diskDevice, [])];

  List<PartedJob> remove() => [
    PartedJob(diskDevice, ["rm", "$partitionNumber"]),
  ];
}
