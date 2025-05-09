import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/runner/exfatprogs/binary.dart';
import 'package:fparted/core/runner/wrapper.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';

final class ExFat extends FileSystemData {
  const ExFat._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
  });
  factory ExFat(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData =
        data ?? FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(Total|Free) Clusters|Cluster size");
    final dumpData = Wrapper.runJobSync(ExfatprogsBinary().dump(partition))
        .stdout
        .toString()
        .split("\n")
        .where((l) => dumpRegex.hasMatch(l))
        .map((l) => l.split(":"))
        .map((l) => (l.first, BigInt.parse(l.last.trim())));
    BigInt getData(String str) => dumpData.firstWhere((l) => l.$1 == str).$2;
    final blockSize = DataSize(getData("Cluster size"));
    return ExFat._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blockSize,
      space: FileSystemSpace.size_free(
        size: DataSize.fromBlock(getData("Total Clusters"), blockSize),
        free: DataSize.fromBlock(getData("Free Clusters"), blockSize),
      ),
    );
  }

  @override
  get canGrow => false;

  @override
  get canShink => false;

  @override
  check() {
    // TODO:
    throw UnimplementedError();
  }

  @override
  label(label) => [ExfatprogsBinary().label(partition, label)];

  @override
  repair() => [
    ExfatprogsBinary().repair(partition),
    // more procedure
  ];

  @override
  get toolChainAvailable => ExfatprogsBinary().isAvailable;
}
