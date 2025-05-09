import 'package:fparted/core/filesystem/fs.dart';
import 'package:fparted/core/model/data_size.dart';
import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/f2fs-tools/binary.dart';
import 'package:fparted/core/runner/wrapper.dart';

final class F2FS extends FileSystemData {
  const F2FS._init({
    required super.partition,
    required super.type,
    required super.name,
    required super.id,
    required super.blockSize,
    required super.space,
  });
  factory F2FS(
    Device partition, [
    FileSystemData? data,
    Map partedOutput = const {},
  ]) {
    final blkidData =
        data ?? FileSystemData.fromPartition(partition, partedOutput);
    final dumpRegex = RegExp(r"^(user|valid)_block_count");
    final dumpData = Wrapper.runJobSync(F2fstoolsBinary().dump(partition))
        .stdout
        .toString()
        .split("\n")
        .where((l) => dumpRegex.hasMatch(l))
        .map((l) => l.split(" "))
        .map((l) => (l.first, BigInt.parse(l.last.replaceFirst("]", ""))));
    BigInt getData(String str) => dumpData.firstWhere((l) => l.$1 == str).$2;
    return F2FS._init(
      partition: partition,
      type: blkidData.type,
      name: blkidData.name,
      id: blkidData.id,
      blockSize: blkidData.blockSize,
      space: FileSystemSpace.size_used(
        size: DataSize.fromBlock(
          getData("user_block_count"),
          blkidData.blockSize,
        ),
        used: DataSize.fromBlock(
          getData("valid_block_count"),
          blkidData.blockSize,
        ),
      ),
    );
  }

  @override
  get canGrow => true;

  @override
  get canShink => false;

  @override
  check() async {
    // TODO:
    throw UnimplementedError();
  }

  @override
  label(label) => [F2fstoolsBinary().label(partition, label)];

  @override
  repair() => [
    F2fstoolsBinary().repair(partition),
    // more procedure
  ];

  @override
  resize(size) => [F2fstoolsBinary().resize(partition, size)];

  @override
  get toolChainAvailable => F2fstoolsBinary().isAvailable;
}
