import 'dart:io';

import 'package:fparted/core/base.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/wrapper/parted/classes.dart';
import 'package:fparted/core/wrapper/wrapper.dart';

class Parted {
  final Disk disk;
  const Parted(this.disk);

  Future<PartedPartitionOperation> partition(int number) async {
    return PartedPartitionOperation(disk: disk, partitionNumber: number);
  }

  Future<ProcessResult> flag(DiskFlag flag, bool enable) async {
    return Wrapper.runParted((
      disk.device,
      ["disk_set", enable ? "on" : "off"],
    ));
  }

  Future<ProcessResult> createTable(PartitionTable table) async {
    return Wrapper.runParted((disk.device, ["mklabel", table.str]));
  }

  Future<ProcessResult> createPart(
    DataSize start,
    DataSize end,
    PartitionType type, [
    PartitionFileSystem? filesystem,
  ]) => Wrapper.runParted((
    disk.device,
    [
      "mkpart",
      type.str,
      ...(filesystem == null ? [] : [filesystem.str]),
      start.byte.toStringAsFixed(2),
      end.byte.toStringAsFixed(2),
    ],
  ));
}

class PartedPartitionOperation {
  final Disk disk;
  final int partitionNumber;

  const PartedPartitionOperation({
    required this.disk,
    required this.partitionNumber,
  });
  factory PartedPartitionOperation.from(Partition partition) {
    return PartedPartitionOperation(
      disk: partition.disk,
      partitionNumber: partition.number,
    );
  }

  Future<ProcessResult> flag(PartitionFlag flag, bool enable) async {
    return Wrapper.runParted((
      disk.device,
      ["set", "$partitionNumber", flag.str, enable ? "on" : "off"],
    ));
  }

  Future<ProcessResult> label(String name) async {
    return Wrapper.runParted((disk.device, ["name", "$partitionNumber", name]));
  }

  Future<ProcessResult> setTypeId(DeviceId id) async {
    return Wrapper.runParted((
      disk.device,
      ["type", "$partitionNumber"],
      //do something with id
    ));
  }

  Future<ProcessResult> resize(DataSize size) async {
    return Wrapper.runParted((disk.device, []));
  }

  Future<ProcessResult> remove() async {
    return Wrapper.runParted((disk.device, ["rm", "$partitionNumber"]));
  }
}
