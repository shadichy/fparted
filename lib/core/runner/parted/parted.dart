import 'package:fparted/core/base.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/parted/binary.dart';
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

  static List<Job> get list => [
    PartedBinary().toJob(
      DeviceJob(fallbackDevice(), ["print", "all"], "List all devices"),
    ),
  ];

  List<Job> flag(DiskFlag flag, bool enable) => [
    PartedBinary().toJob(
      DeviceJob(
        disk.device,
        ["disk_set", enable ? "on" : "off"],
        "Set flag ${flag.name} state of disk ${disk.device} to ${enable ? "on" : "off"}",
      ),
    ),
  ];

  List<Job> createTable(PartitionTable table) => [
    PartedBinary().toJob(
      DeviceJob(
        disk.device,
        ["mklabel", table.str],
        "Create partition table ${table.name} on disk ${disk.device}",
      ),
    ),
  ];

  List<Job> createPart(
    DataSize start,
    DataSize end,
    PartitionType type, [
    PartitionFileSystem? filesystem,
  ]) => [
    PartedBinary().toJob(
      DeviceJob(
        disk.device,
        [
          "mkpart",
          type.str,
          ...(filesystem == null ? [] : [filesystem.str]),
          start.byte.toStringAsFixed(2),
          end.byte.toStringAsFixed(2),
        ],
        "Create a ${(end - start).humanReadable()} partition on disk ${disk.device} type ${type.name}",
      ),
    ),
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

  List<Job> flag(PartitionFlag flag, bool enable) => [
    PartedBinary().toJob(
      DeviceJob(
        diskDevice,
        ["set", "$partitionNumber", flag.str, enable ? "on" : "off"],
        "Set flag ${flag.name} state on disk $diskDevice partition $partitionNumber to ${enable ? "on" : "off"}",
      ),
    ),
  ];

  List<Job> label(String name) => [
    PartedBinary().toJob(
      DeviceJob(
        diskDevice,
        ["name", "$partitionNumber", name],
        "Set name on disk $diskDevice partition $partitionNumber to $name",
      ),
    ),
  ];

  List<Job> setTypeId(DeviceId id) => [
    PartedBinary().toJob(
      DeviceJob(
        diskDevice,
        ["type", "$partitionNumber"],
        //do something with id
        "Set type ID on disk $diskDevice partition $partitionNumber to $id",
      ),
    ),
  ];

  List<Job> resize(DataSize size) => [
    PartedBinary().toJob(
      DeviceJob(
        diskDevice,
        [],
        "Resize partition $partitionNumber on disk $diskDevice to $size",
      ),
    ),
  ];

  List<Job> remove() => [
    PartedBinary().toJob(
      DeviceJob(diskDevice, [
        "rm",
        "$partitionNumber",
      ], "Remove partition $partitionNumber from disk $diskDevice"),
    ),
  ];
}
