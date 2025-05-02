import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/wrapper/exfatprogs/binary.dart';
import 'package:fparted/core/wrapper/wrapper.dart';
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
  factory ExFat(Device partition, [Map partedOutput = const {}]) {
    final blkidData = FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(Total|Free) Clusters|Cluster size");
    final dumpData = Wrapper.runCmdSync(ExfatprogsBinary().dump(partition))
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
  check() async {
    // TODO:
    throw UnimplementedError();
  }

  @override
  checkSync() {
    // TODO:
    throw UnimplementedError();
  }

  @override
  label(label) async {
    return await Wrapper.runCmd(ExfatprogsBinary().label(partition, label));
  }

  @override
  labelSync(label) {
    return Wrapper.runCmdSync(ExfatprogsBinary().label(partition, label));
  }

  @override
  repair() async {
    return await Wrapper.runCmd(ExfatprogsBinary().repair(partition));
    // more procedure
  }

  @override
  repairSync() {
    return Wrapper.runCmdSync(ExfatprogsBinary().repair(partition));
  }

  @override
  get toolChainAvailable => ExfatprogsBinary().isAvailable;
}
