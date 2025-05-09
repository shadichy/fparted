import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/btrfs-progs/binary.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/wrapper.dart';

final class BtrFS extends FileSystemData {
  const BtrFS._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
  });
  factory BtrFS(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData =
        data ?? FileSystemData.fromPartition(partition, partedOutput);
    final dumpData = Wrapper.runJobSync(
      BtrfsprogsBinary().dump(partition),
    ).stdout.toString().split("\n").last.split(" size ").last.split(" used ");
    return BtrFS._init(
      partition: partition,
      type: FileSystem.btrfs,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blkidData.blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.parse(dumpData.first),
        used: DataSize.parse(dumpData.last.split(" ").first),
      ),
    );
  }

  @override
  get canGrow => true;

  @override
  get canShink => true;

  @override
  check() => [
    Job(BtrfsprogsBinary().binaryMap["btrfs"] ?? "btrfs", [
      "check",
      partition.raw,
    ]),
  ];

  @override
  label(label) => [BtrfsprogsBinary().label(partition, label)];

  @override
  repair() => [
    BtrfsprogsBinary().repair(partition),
    // more procedure
  ];

  @override
  resize(size) => [BtrfsprogsBinary().resize(partition, size)];

  @override
  get toolChainAvailable => BtrfsprogsBinary().isAvailable;
}
